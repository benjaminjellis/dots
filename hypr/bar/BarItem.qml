import QtQuick

Rectangle {
    id: item
    property alias text: label.text
    property color foreground: "#000000"
    property bool bevel: true
    property bool selected: false
    property int minimumWidth: 0
    property int padding: 7
    property alias hovered: pointer.containsMouse
    signal clicked(int button)
    signal scrolled(int delta)

    implicitWidth: Math.max(minimumWidth, Math.ceil(label.implicitWidth) + 2 * padding)
    color: selected ? "#000000" : bevel ? "#e8ecec" : "transparent"

    Rectangle {
        visible: item.bevel && !item.selected
        anchors.fill: parent
        color: "transparent"
        border.color: "#7b8484"
        Rectangle { width: parent.width - 1; height: 1; color: "white" }
        Rectangle { width: 1; height: parent.height - 1; color: "white" }
    }

    Text {
        id: label
        anchors.centerIn: parent
        textFormat: Text.PlainText
        color: item.selected ? "white" : item.foreground
        font.family: "ChiKareGo2"
        font.pixelSize: 16
        font.bold: true
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => item.clicked(mouse.button)
        onWheel: wheel => item.scrolled(wheel.angleDelta.y)
    }
}
