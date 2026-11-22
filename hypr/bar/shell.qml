// @ pragma UseQApplication
import QtQuick
import Quickshell
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
    property string brightness: ""
    property bool keepAwake: false
    property bool showBatteryPercent: true
    readonly property var battery: UPower.displayDevice
    readonly property var audio: Pipewire.defaultAudioSink?.audio
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
        backlightStatus.running = true
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }
    PwObjectTracker { objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : [] }

    Timer { interval: 5000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refreshStatus() }
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
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL device wifi list --rescan no; nmcli -t -f DEVICE,TYPE,STATE device status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const active = text.match(/^\*:(\d+)$/m)
                const wired = text.match(/^([^:\n]+):ethernet:connected$/m)
                root.network = active ? ", (" + active[1] + "%)" : wired ? " " + wired[1] : ""
            }
        }
    }
    Process {
        id: backlightStatus
        command: ["brightnessctl", "-c", "backlight", "-m"]
        stdout: StdioCollector {
            onStreamFinished: root.brightness = text.trim().split(",")[3] || ""
        }
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
                            model: SystemTray.items
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
                BarItem {
                    height: parent.height
                    text: root.keepAwake ? "" : ""
                    selected: root.keepAwake
                    onClicked: root.keepAwake = !root.keepAwake
                }
                BarItem {
                    height: parent.height
                    text: root.network || "󰖪"
                    selected: !root.network
                }
                BarItem {
                    height: parent.height
                    visible: !!root.vpn.text
                    text: root.vpn.text || ""
                    foreground: root.vpn.class === "connected" ? "#175c2c" : "#790000"
                    selected: root.vpn.class === "unknown"
                }
                BarItem {
                    height: parent.height
                    visible: !!root.audio
                    text: root.audio?.muted ? "󰝟" : " " + Math.round((root.audio?.volume || 0) * 100) + "%"
                    selected: root.audio?.muted ?? false
                    onClicked: { if (root.audio) root.audio.muted = !root.audio.muted }
                    onScrolled: delta => {
                        if (root.audio && delta)
                            root.audio.volume = Math.min(1, Math.max(0, root.audio.volume + Math.sign(delta) * 0.05))
                    }
                }
                BarItem {
                    height: parent.height
                    visible: !!root.brightness
                    text: "󰃠 " + root.brightness
                    onScrolled: delta => {
                        if (delta) Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", delta > 0 ? "5%+" : "5%-"])
                    }
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
