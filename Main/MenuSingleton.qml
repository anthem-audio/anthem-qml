/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.13
import QtGraphicalEffects 1.13
import io.github.anthem.utilities.mousehelper 1.0

/*
 * Utility component that draws individual menus.
 *
 *
 * Note:
 * This class has duplicate Column components that
 * separately deal with menu rendering and MouseArea
 * positioning. This is because the visible part of
 * the menu has visible: false and is instead
 * rendered through an OpacityMask, this to round the
 * corners of highlighted menu items properly.
 * MouseAreas contained in a non-visible component do
 * not work, so the MouseAreas must be positioned in a
 * separate component. This is not optimal, but it
 * seems to be unavoidable.
 */

Rectangle {
    property var menuItems
    property int _ignoredItemsCount: menuItems.filter(item => item.separator).length
    property int selectedIndex: -1
    property real hue: 162 / 360
    property string id
    signal closed()
    color: Qt.rgba(0, 0, 0, 0.72)
    radius: 6
    height: menuContent.height

    MouseHelper {
        id: mouseHelper
    }

    function moveMouseTo(index) {
        let newSelectedElement = menuContentRepeater.itemAt(index);
        let newMousePos = mapToGlobal(newSelectedElement.x + newSelectedElement.width * 0.7, newSelectedElement.y + newSelectedElement.height * 0.5);
        mouseHelper.setCursorPosition(newMousePos.x, newMousePos.y);
    }

    Column {
        id: menuContent
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        visible: false
        Repeater {
            id: menuContentRepeater
            anchors.fill: parent
            model: menuItems

            Rectangle {
                width: parent.width
                height: modelData.separator ? 1 : 21
                color: !modelData.separator && (index == selectedIndex) ? Qt.hsla(hue, 0.5, 0.43, 1) : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 7
                    anchors.left: parent.left
                    text: modelData.text ? qsTr(modelData.text) : ""
                    color: index == selectedIndex ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(1, 1, 1, 65);
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    color: modelData.separator ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            selectedIndex = -1;
        }

        Column {
            id: menuMouseAreas
            anchors.fill: parent
            Repeater {
                anchors.fill: parent
                model: menuItems

                Item {
                    width: parent.width
                    height: modelData.separator ? 1 : 21
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                        onEntered: {
                            selectedIndex = index;
                        }
                        onPressed: {
                            menuItems[index].onTriggered();
                            closed();
                        }
                        onWheel: {
                            if (_ignoredItemsCount === menuItems.length)
                                return;

                            let step = wheel.angleDelta.y < 0 ? -1 : 1;
                            let stepsRemaining = Math.abs(wheel.angleDelta.y) % (menuItems.length - _ignoredItemsCount);
                            let tempSelectedIndex = selectedIndex;
                            for (let i = 0; i < stepsRemaining; i++) {
                                tempSelectedIndex += step;
                                while (menuItems[tempSelectedIndex] !== undefined && menuItems[tempSelectedIndex].separator !== undefined) {
                                    tempSelectedIndex += step;
                                }
                                tempSelectedIndex = (tempSelectedIndex + menuItems.length) % menuItems.length;
                            }
                            selectedIndex = tempSelectedIndex;
                            moveMouseTo(selectedIndex);
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: mask
        anchors.fill: parent
        radius: 6
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: menuContent
        maskSource: mask
    }
}
