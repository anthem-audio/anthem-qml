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
import QtQuick.Shapes 1.13

import "Global"

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
    property int attemptedSelectedIndex: -1
    property real hue: 162 / 360
    property int id
    property bool isSubmenuOpen: false
    property bool blockIndexChange: false
    property real currentSubmenuX
    property real currentSubmenuY
    signal closed(int id)
    signal closeSubmenus(int id)
    signal openSubmenu(real x, real y, var items)
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

    function submenuClicked(x, y, index) {
        if (isSubmenuOpen)
            return;
        blockIndexChange = true;
        timer.setTimeout(() => {
            blockIndexChange = false;
            if (index !== attemptedSelectedIndex) {
                selectedIndex = attemptedSelectedIndex;
                closeSubmenus(id);
                isSubmenuOpen = false;
                if (menuItems[selectedIndex].submenu) {
                    timer.setTimeout(() => {
                        submenuClicked(currentSubmenuX, currentSubmenuY, selectedIndex);
                    }, 500);
                }
            }
        }, 1000);
        isSubmenuOpen = true;
        openSubmenu(x, y, menuItems[index].submenu);
    }

    // https://stackoverflow.com/a/50224584/8166701
    Timer {
        id: timer
        function setTimeout(callback, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(callback);
            timer.triggered.connect(function release () {
                timer.triggered.disconnect(callback);
                timer.triggered.disconnect(release);
            });
            timer.start();
        }
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
                property color contentColor: index == selectedIndex ? Qt.rgba(0, 0, 0, 0.7) : Qt.rgba(1, 1, 1, 65);
                color: !modelData.separator && (index == selectedIndex) ? Qt.hsla(hue, 0.5, 0.43, 1) : "transparent"
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1
                    anchors.leftMargin: 7
                    anchors.left: parent.left
                    font.family: Fonts.notoSansRegular.name
                    font.pixelSize: 11
                    text: modelData.text ? qsTr(modelData.text) : ""
                    color: contentColor
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 7
                    anchors.rightMargin: 7
                    color: modelData.separator ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                }

                Shape {
                    id: arrow
                    width: parent.height * 0.3
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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            // If the user moved to a submenu, make sure the
            // blockIndexChange reset timer doesn't close their
            // submenu when the timer runs out
            attemptedSelectedIndex = selectedIndex;

            if (blockIndexChange)
                return;
            if (isSubmenuOpen) {
                closeSubmenus(id);
                isSubmenuOpen = false;
            }

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
                            attemptedSelectedIndex = index;
                            if (menuItems[index].submenu) {
                                let submenuPos = mapToGlobal(x + width, y);
                                let windowPos = menuHelper.mapToGlobal(0, 0);
                                currentSubmenuX = submenuPos.x - windowPos.x;
                                currentSubmenuY = submenuPos.y - windowPos.y;
                            }

                            if (blockIndexChange)
                                return;
                            if (isSubmenuOpen) {
                                closeSubmenus(id);
                                isSubmenuOpen = false;
                            }

                            selectedIndex = index;
                            if (menuItems[index].submenu) {
                                timer.setTimeout(() => {
                                    if (index === selectedIndex) {
                                        submenuClicked(currentSubmenuX, currentSubmenuY, index);
                                    }
                                }, 500);
                            }
                        }
                        onPressed: {
                            if (menuItems[index].onTriggered)
                                menuItems[index].onTriggered();
                            if (menuItems[index].submenu) {
                                let submenuPos = mapToGlobal(x + width, y);
                                let windowPos = menuHelper.mapToGlobal(0, 0);
                                submenuClicked(submenuPos.x - windowPos.x, submenuPos.y - windowPos.y, index);
                            }
                            else
                                closed(id);
                        }
                        onWheel: {
                            if (_ignoredItemsCount === menuItems.length)
                                return;

                            let step = wheel.angleDelta.y < 0 ? -1 : 1;
                            let tempSelectedIndex = selectedIndex;
                            tempSelectedIndex += step;
                            while (menuItems[tempSelectedIndex] !== undefined && menuItems[tempSelectedIndex].separator !== undefined) {
                                tempSelectedIndex += step;
                            }
                            tempSelectedIndex = (tempSelectedIndex + menuItems.length) % menuItems.length;
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
