import QtQuick
import Quickshell
import Quickshell.Services.UPower

BarItem {
    id: item
    property var device
    property bool onBattery
    property bool showPercentage
    signal togglePercentage()
    readonly property int percent: Math.round((device?.percentage || 0) * 100)
    readonly property bool charging: device?.state === UPowerDeviceState.Charging
    readonly property bool full: device?.state === UPowerDeviceState.FullyCharged
    readonly property real remainingSeconds: charging ? (device?.timeToFull || 0) : onBattery ? (device?.timeToEmpty || 0) : 0
    readonly property real changeRate: device?.changeRate || 0
    readonly property var levelIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargeIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property int iconIndex: Math.max(0, Math.min(9, Math.floor((device?.percentage || 0) * 10)))

    visible: device?.isPresent ?? false
    selected: onBattery && percent <= 30
    text: (full ? chargeIcons[9] : (charging ? chargeIcons : levelIcons)[iconIndex]) + (showPercentage ? " " + percent + "%" : "")
    onClicked: button => {
        if (button === Qt.RightButton) togglePercentage()
        else if (button === Qt.LeftButton) details.visible = !details.visible
    }

    PopupWindow {
        id: details
        anchor.item: item
        implicitWidth: panel.implicitWidth
        implicitHeight: panel.implicitHeight
        color: "#e8ecec"

        BarItem {
            id: panel
            anchors.fill: parent
            minimumWidth: 210
            implicitHeight: 82
            text: {
                const power = item.onBattery ? "Charger disconnected" : "Charger connected"
                const state = item.full ? " · Fully charged" : item.charging ? " · Charging" : ""
                const minutes = Math.ceil(item.remainingSeconds / 60)
                const duration = minutes >= 60 ? Math.floor(minutes / 60) + "h " + minutes % 60 + "m" : minutes + "m"
                const estimate = minutes > 0 ? duration + (item.charging ? " to full" : " remaining") : "Time estimate unavailable"
                const rate = item.changeRate > 0 ? item.changeRate.toFixed(1) + " W " + (item.charging ? "charging" : "discharging") : "Charge rate unavailable"
                return item.percent + "%" + state + "\n" + power + "\n" + estimate + "\n" + rate
            }
            onClicked: details.visible = false
        }
    }
}
