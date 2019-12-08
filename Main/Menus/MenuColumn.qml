/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.13
import QtQuick.Shapes 1.13

import "../Global"

Column {
    property var columnItems

    function itemAt(index) {
        return repeater.itemAt(index);
    }

    property real calculatedHeight: 0
    height: calculatedHeight

    Component.onCompleted: {
        let h = 0;
        for (let item of columnItems) {
            h += item.separator ? 7 : 21;
        }
        calculatedHeight = h;
    }

    Repeater {
        id: repeater
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: calculatedHeight
        model: columnItems

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
//                    width: parent.width - 21 - shortcutText.width - (columnItems[index].submenu ? 10 : 0)
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
                    let menuItemWidth = width + 14 + shortcutText.width + (modelData.shortcut ? 14 : 0) + (columnItems[index].submenu ? 14 : 0);
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
