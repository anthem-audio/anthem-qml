import QtQuick 2.13
import QtQuick.Shapes 1.13

import "../Global"

Column {
    property var columnItems

    function itemAt(index) {
        return repeater.itemAt(index);
    }

    Repeater {
        id: repeater
        anchors.fill: parent
        model: menuItems

        Rectangle {
            width: parent.width
            height: modelData.separator ? 7 : 21
            property color contentColor: {
                if (modelData.separator) {
                    return "transparent";
                }
                else if (modelData.disabled) {
                    return Qt.rgba(1, 1, 1, 0.35);
                }
                else {
                    return index === selectedIndex ? Qt.rgba(0, 0, 0, 0.9) : Qt.rgba(1, 1, 1, 0.65);
                }
            }

            property color secondaryColor: {
                if (modelData.separator) {
                    return "transparent";
                }
                else if (modelData.disabled) {
                    return Qt.rgba(1, 1, 1, 0.25);
                }
                else {
                    return index === selectedIndex ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(1, 1, 1, 0.45);
                }
            }

            color: {
                if (modelData.disabled) {
                    return Qt.rgba(0, 0, 0, 0.55);
                }

                return !modelData.separator && (index == selectedIndex) ? Qt.hsla(hue, 0.5, 0.43, 1) : Qt.rgba(0, 0, 0, 0.72)
            }
            Text {
//                    width: parent.width - 21 - shortcutText.width - (menuItems[index].submenu ? 10 : 0)
                elide: Text.ElideMiddle

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                anchors.left: parent.left
                anchors.leftMargin: 7
                anchors.right: shortcutText.left
                anchors.rightMargin: modelData.shortcut ? 14 : 0
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 11
                text: modelData.text ? qsTr(modelData.text) : ""
                color: contentColor
            }

            // This is used for calculating what the text
            // width would be if there were no max width
            Text {
                visible: false

                onWidthChanged: {
                    let menuItemWidth = width + 14 + shortcutText.width + (modelData.shortcut ? 14 : 0) + (menuItems[index].submenu ? 14 : 0);
                    if (menuItemWidth > _biggestItemWidth) {
                        _biggestItemWidth = menuItemWidth;
                    }
                }

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                anchors.leftMargin: 7
                anchors.left: parent.left
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 11
                text: modelData.text ? qsTr(modelData.text) : ""
            }

            Text {
                id: shortcutText
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                anchors.rightMargin: modelData.submenu ? 7 : 0
                anchors.right: arrow.left
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 9
                text: modelData.shortcut ? modelData.shortcut : ""
                color: secondaryColor
            }

            Rectangle {
                height: 1
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 7
                    rightMargin: 7
                    verticalCenter: parent.verticalCenter
                }

                visible: modelData.separator ? true : false
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Shape {
                id: arrow
                width: modelData.submenu ? parent.height * 0.3 : 0
                visible: modelData.submenu !== undefined
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: parent.height * 0.35
                    bottomMargin: parent.height * 0.35
                    rightMargin: 7
                }

                ShapePath {
                    strokeColor: contentColor
                    strokeWidth: 1
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin

                    startX: arrow.width * 0.5
                    startY: 0

                    PathLine { x: arrow.width; y: arrow.height * 0.5; }
                    PathLine { x: arrow.width * 0.5; y: arrow.height; }
                }
            }
        }
    }
}
