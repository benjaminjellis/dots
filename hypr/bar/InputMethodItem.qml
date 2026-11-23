import QtQuick
import Quickshell

BarItem {
    id: item
    property var entry
    readonly property string modeIcon: entry?.icon || ""

    visible: !!entry
    minimumWidth: 34
    text: {
        if (modeIcon.includes("hiragana") || modeIcon.includes("katakana")) return "あ"
        if (modeIcon.includes("alpha_") || modeIcon.includes("direct") || modeIcon.includes("keyboard")) return "A"
        return entry?.tooltipTitle || "IME"
    }
    onClicked: button => {
        if (!entry) return
        if (button === Qt.LeftButton) entry.activate()
        else if (button === Qt.RightButton && entry.hasMenu) menu.open()
    }

    QsMenuAnchor {
        id: menu
        menu: item.entry?.menu ?? null
        anchor.item: item
    }
}
