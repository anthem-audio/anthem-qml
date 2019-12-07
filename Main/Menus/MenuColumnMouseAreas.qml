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

Column {
    property var columnItems
    anchors.fill: parent
    Repeater {
        anchors.fill: parent
        model: columnItems

        Item {
            width: parent.width
            height: modelData.separator ? 7 : 21

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    selectedIndex = index;
                    attemptedSelectedIndex = index;

                    Anthem.displayStatusMessage(modelData.hoverText ? modelData.hoverText : '');

                    if (openedSubmenuIndex > -1 && !blockSubmenuClose) {
                        closeSubmenus(id);
                        openedSubmenuIndex = -1;
                    }

                    if (modelData.separator || modelData.disabled) {
                        return;
                    }

                    if (columnItems[index].submenu) {
                        let submenuPos = mapToGlobal(x + width, y);
                        let menuPos = mapToGlobal(x, y);
                        let windowPos = menuHelper.mapToGlobal(0, 0);
                        currentSubmenuX = submenuPos.x - windowPos.x;
                        currentSubmenuY = submenuPos.y - windowPos.y;
                        currentSubmenuAltX = menuPos.x - windowPos.x;
                        currentSubmenuAltY = menuPos.y - windowPos.y;
                    }

                    if (columnItems[index].submenu) {
                        timer.setTimeout(() => {
                            if (index === selectedIndex) {
                                submenuClicked(currentSubmenuX, currentSubmenuY, currentSubmenuAltX, currentSubmenuAltY, index);
                            }
                        }, 500);
                    }
                }
                onPressed: {
                    if (modelData.separator || modelData.disabled) {
                        return;
                    }

                    if (columnItems[index].onTriggered)
                        columnItems[index].onTriggered();
                    if (columnItems[index].submenu) {
                        let submenuPos = mapToGlobal(x + width, y);
                        let menuPos = mapToGlobal(x, y);
                        let windowPos = menuHelper.mapToGlobal(0, 0);
                        submenuClicked(submenuPos.x - windowPos.x, submenuPos.y - windowPos.y, menuPos.x - windowPos.x, menuPos.y - windowPos.y, index);
                    }
                    else
                        closeAll();
                }
                onWheel: {
                    if (_ignoredItemsCount === columnItems.length)
                        return;

                    let step = wheel.angleDelta.y < 0 ? -1 : 1;
                    let tempSelectedIndex = selectedIndex;
                    tempSelectedIndex += step;

                    tempSelectedIndex = (tempSelectedIndex + columnItems.length) % columnItems.length;
                    while (columnItems[tempSelectedIndex] !== undefined && (columnItems[tempSelectedIndex].separator || columnItems[tempSelectedIndex].disabled)) {
                        tempSelectedIndex += step;
                        tempSelectedIndex = (tempSelectedIndex + columnItems.length) % columnItems.length;
                    }

                    selectedIndex = tempSelectedIndex;
                    moveMouseTo(selectedIndex);
                }
            }
        }
    }
}
