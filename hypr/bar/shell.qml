// @ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Wayland

ShellRoot {
    id: root
    property var vpn: ({})
    property string network: ""
    property string networkDetails: "Disconnected"
    property string brightness: ""
    property int pendingBrightnessStep: 0
    property string overlayLabel: ""
    property int overlayPercent: 0
    property string overlayScreen: ""
    readonly property bool showBrightness: Quickshell.env("DOTS_BAR_BRIGHTNESS") === "1"
    property bool keepAwake: false
    property bool showBatteryPercent: true
    readonly property var inputMethod: SystemTray.items.values.find(item => item.id.toLowerCase() === "fcitx") || null
    readonly property var battery: UPower.displayDevice
    readonly property var audio: Pipewire.defaultAudioSink?.audio
    readonly property var audioOutputs: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream)
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothConnected: Bluetooth.devices.values.some(device => device.connected)
    readonly property var workspaces: {
        const ids = new Set([1, 2, 3, 4, 5])
        for (const workspace of Hyprland.workspaces.values)
            if (workspace.id > 0) ids.add(workspace.id)
        return Array.from(ids).sort((a, b) => a - b)
    }
    readonly property var workspaceIcons: ({1: "", 2: "", 3: "󰈹", 5: "󱎏", 7: "󰒱"})

    function refreshStatus() {
        vpnStatus.running = true
        networkStatus.running = true
    }

    function toggleBluetooth() {
        if (bluetoothAdapter)
            Quickshell.execDetached(["bluetoothctl", "power", bluetoothAdapter.enabled ? "off" : "on"])
    }

    function applyBrightnessStep() {
        if (setBacklight.running || !pendingBrightnessStep) return
        const step = pendingBrightnessStep
        pendingBrightnessStep = 0
        setBacklight.command = ["brightnessctl", "-c", "backlight", "-m", "set", Math.abs(step) + (step > 0 ? "%+" : "%-")]
        setBacklight.running = true
    }

    function changeBrightness(step) {
        pendingBrightnessStep += step
        applyBrightnessStep()
    }

    function showOverlay(label, percent) {
        overlayLabel = label
        overlayPercent = percent
        overlayScreen = Hyprland.focusedMonitor?.name || Quickshell.screens[0]?.name || ""
        overlayTimeout.restart()
    }

    function showVolume() {
        if (!audio) return
        showOverlay(audio.muted ? "Volume muted" : "Volume", audio.muted ? 0 : Math.round(audio.volume * 100))
    }

    IpcHandler {
        target: "barBrightness"
        function step(amount: int): void {
            if (root.showBrightness) root.changeBrightness(Math.max(-100, Math.min(100, amount)))
        }
    }

    Connections {
        target: root.audio || null
        function onVolumesChanged() { root.showVolume() }
        function onMutedChanged() { root.showVolume() }
    }

    Timer { id: overlayTimeout; interval: 1400 }

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : [] }

    Timer { interval: 5000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refreshStatus() }
    Timer {
        interval: 1000
        repeat: true
        running: root.showBrightness
        triggeredOnStart: true
        onTriggered: { if (!setBacklight.running) backlightStatus.running = true }
    }
    Process {
        id: vpnStatus
        command: ["python3", Quickshell.env("HOME") + "/.config/hypr/bar/protonvpn-status.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.vpn = JSON.parse(text) }
                catch (error) { root.vpn = {} }
            }
        }
    }
    Process {
        id: networkStatus
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL,SSID device wifi list --rescan no; nmcli -m multiline -f GENERAL.DEVICE,GENERAL.TYPE,GENERAL.STATE,IP4.ADDRESS,IP6.ADDRESS device show"]
        environment: ({ LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: {
                const wifi = text.match(/^\*:(\d+):(.*)$/m)
                const connected = text.split(/^GENERAL\.DEVICE:[ \t]*/m).slice(1)
                    .filter(device => /^GENERAL\.STATE:[ \t]*100\b/m.test(device))
                const wireless = connected.find(device => /^GENERAL\.TYPE:[ \t]*wifi$/m.test(device))
                const wired = connected.find(device => /^GENERAL\.TYPE:[ \t]*ethernet$/m.test(device))
                const device = wireless || wired
                const name = device?.split("\n")[0]?.trim()
                const ssid = wifi?.[2].replace(/\\([:\\])/g, "$1")
                const address = device?.match(/^IP4\.ADDRESS\[\d+\]:[ \t]*([^/\s]+)/m)?.[1]
                    || device?.match(/^IP6\.ADDRESS\[\d+\]:[ \t]*([^/\s]+)/m)?.[1]
                root.network = wireless ? (wifi ? ", (" + wifi[1] + "%)" : "") : wired ? " " + name : ""
                root.networkDetails = device ? (wireless ? ssid || name : name) + "\n" + (address || "No local IP") : "Disconnected"
            }
        }
    }
    Process {
        id: backlightStatus
        command: ["brightnessctl", "-c", "backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!setBacklight.running) root.brightness = text.trim().split(",")[3] || ""
            }
        }
    }
    Process {
        id: setBacklight
        stdout: StdioCollector {
            onStreamFinished: {
                const percent = text.trim().split(",")[3]
                if (/^\d+%$/.test(percent || "")) {
                    root.brightness = percent
                    root.showOverlay("Brightness", parseInt(percent, 10))
                }
            }
        }
        onRunningChanged: { if (!running) root.applyBrightnessStep() }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 26
            WlrLayershell.namespace: "quickshell-bar"
            color: "#dee2e2"

            PanelWindow {
                screen: bar.screen
                visible: overlayTimeout.running && root.overlayScreen === screen?.name
                anchors.bottom: true
                margins.bottom: 80
                implicitWidth: 232
                implicitHeight: 66
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.namespace: "quickshell-system7-osd"
                WlrLayershell.layer: WlrLayer.Overlay
                mask: Region {}
                color: "#000000"

                BarItem {
                    anchors { fill: parent; rightMargin: 3; bottomMargin: 3 }
                    text: ""

                    Text {
                        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 9 }
                        text: root.overlayLabel + "  " + root.overlayPercent + "%"
                        textFormat: Text.PlainText
                        font { family: "ChiKareGo2"; pixelSize: 18; bold: true }
                        color: "#000000"
                    }
                    Rectangle {
                        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 12 }
                        height: 14
                        color: "#f8f9f9"
                        border.color: "#000000"

                        Rectangle {
                            x: 2
                            y: 2
                            width: Math.round((parent.width - 4) * Math.max(0, Math.min(100, root.overlayPercent)) / 100)
                            height: parent.height - 4
                            color: "#000000"
                        }
                    }
                }
            }

            IdleInhibitor { window: bar; enabled: root.keepAwake }

            Repeater {
                model: 12
                Rectangle { required property int index; width: bar.width; y: 2 * index + 1; height: 1; color: "#f8f9f9" }
            }
            Rectangle { width: parent.width; height: 1; color: "white" }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#8a9292" }

            Row {
                anchors { left: parent.left; leftMargin: 4; top: parent.top; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }

                BarItem {
                    height: parent.height
                    text: ""
                    bevel: false
                    selected: hovered
                    onClicked: Quickshell.execDetached(["hyprlauncher"])
                }
                Item { width: 10; height: 1 }
                Repeater {
                    model: root.workspaces
                    BarItem {
                        required property int modelData
                        height: parent.height
                        bevel: false
                        minimumWidth: 34
                        text: root.workspaceIcons[modelData] || String(modelData)
                        selected: hovered || Hyprland.monitorFor(bar.screen)?.activeWorkspace?.id === modelData
                        onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "' + modelData + '" })')
                        onScrolled: delta => {
                            if (delta) Hyprland.dispatch('hl.dsp.focus({ workspace = "' + (delta > 0 ? "e+1" : "e-1") + '" })')
                        }
                    }
                }
            }

            Row {
                anchors { right: parent.right; rightMargin: 4; top: parent.top; bottom: parent.bottom; topMargin: 2; bottomMargin: 2 }
                spacing: 4

                Rectangle {
                    height: parent.height
                    width: tray.implicitWidth + 10
                    visible: tray.implicitWidth > 0
                    color: "#e8ecec"
                    border.color: "#7b8484"

                    Row {
                        id: tray
                        anchors.centerIn: parent
                        spacing: 4
                        Repeater {
                            model: SystemTray.items.values.filter(item => item.id !== "blueman" && item !== root.inputMethod)
                            Item {
                                id: trayIcon
                                required property var modelData
                                width: 16
                                height: 16
                                Image { anchors.fill: parent; source: trayIcon.modelData.icon }
                                QsMenuAnchor {
                                    id: menu
                                    menu: trayIcon.modelData.menu
                                    anchor.item: parent
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    onClicked: mouse => {
                                        const entry = trayIcon.modelData
                                        if ((mouse.button === Qt.RightButton || entry.onlyMenu) && entry.hasMenu) menu.open()
                                        else if (mouse.button === Qt.MiddleButton) entry.secondaryActivate()
                                        else if (mouse.button === Qt.LeftButton) entry.activate()
                                    }
                                }
                            }
                        }
                    }
                }
                InputMethodItem {
                    height: parent.height
                    entry: root.inputMethod
                }
                BarItem {
                    height: parent.height
                    text: root.keepAwake ? "" : ""
                    selected: root.keepAwake
                    onClicked: root.keepAwake = !root.keepAwake
                }
                BarItem {
                    height: parent.height
                    visible: !!root.bluetoothAdapter
                    text: !root.bluetoothAdapter?.enabled ? "󰂲" : root.bluetoothConnected ? "󰂱" : "󰂯"
                    onClicked: button => {
                        if (button === Qt.LeftButton) Quickshell.execDetached(["blueman-manager"])
                        else if (button === Qt.RightButton) root.toggleBluetooth()
                    }
                }
                BarItem {
                    id: networkButton
                    height: parent.height
                    text: root.network || "󰖪"
                    selected: !root.network
                    onClicked: button => {
                        if (button === Qt.LeftButton) Quickshell.execDetached(["ghostty", "-e", "nmtui"])
                    }

                    Timer {
                        id: networkHover
                        interval: 350
                        running: networkButton.hovered
                    }
                    PopupWindow {
                        anchor.item: networkButton
                        visible: networkButton.hovered && !networkHover.running
                        implicitWidth: networkInfo.implicitWidth
                        implicitHeight: networkInfo.implicitHeight
                        color: "#e8ecec"

                        BarItem {
                            id: networkInfo
                            anchors.fill: parent
                            minimumWidth: 120
                            implicitHeight: 46
                            text: root.networkDetails
                        }
                    }
                }
                BarItem {
                    height: parent.height
                    visible: !!root.vpn.text
                    text: root.vpn.text || ""
                    foreground: root.vpn.class === "connected" ? "#175c2c" : "#790000"
                    selected: root.vpn.class === "unknown"
                }
                BarItem {
                    id: volumeButton
                    height: parent.height
                    visible: !!root.audio
                    text: root.audio?.muted ? "󰝟" : " " + Math.round((root.audio?.volume || 0) * 100) + "%"
                    selected: root.audio?.muted ?? false
                    onClicked: button => {
                        if (button === Qt.LeftButton && root.audio) root.audio.muted = !root.audio.muted
                        else if (button === Qt.RightButton) audioPicker.visible = !audioPicker.visible
                    }
                    onScrolled: delta => {
                        if (root.audio && delta)
                            root.audio.volume = Math.min(1, Math.max(0, root.audio.volume + Math.sign(delta) * 0.05))
                    }

                    PopupWindow {
                        id: audioPicker
                        anchor.item: volumeButton
                        implicitWidth: outputRows.implicitWidth + 8
                        implicitHeight: outputRows.implicitHeight + 8
                        color: "#dee2e2"

                        Column {
                            id: outputRows
                            x: 4
                            y: 4
                            spacing: 4

                            Repeater {
                                model: root.audioOutputs
                                BarItem {
                                    required property var modelData
                                    height: 26
                                    minimumWidth: 180
                                    selected: modelData === Pipewire.defaultAudioSink
                                    text: modelData.description || modelData.nickname || modelData.name
                                    onClicked: button => {
                                        if (button !== Qt.LeftButton) return
                                        Pipewire.preferredDefaultAudioSink = modelData
                                        audioPicker.visible = false
                                    }
                                }
                            }
                        }
                    }
                }
                BarItem {
                    height: parent.height
                    visible: root.showBrightness && !!root.brightness
                    text: "󰃠 " + root.brightness
                    onScrolled: delta => root.changeBrightness(Math.sign(delta) * 5)
                }
                BatteryItem {
                    height: parent.height
                    device: root.battery
                    onBattery: UPower.onBattery
                    showPercentage: root.showBatteryPercent
                    onTogglePercentage: root.showBatteryPercent = !root.showBatteryPercent
                }
                BarItem {
                    height: parent.height
                    minimumWidth: 176
                    text: Qt.formatDateTime(clock.date, "ddd MMM dd  hh:mm AP")
                }
            }
        }
    }
}
