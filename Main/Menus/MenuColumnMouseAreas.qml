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

/*
  Hey fellow maintainer.

  I'm writing this at 3 in the morning so bear with me.
  I think this is the point where I should feel even a shred
  of remorse for coding fully custom menus for Anthem, but I
  lost that a long time ago, probably when I started writing
  a fully custom menu instead of using stock OS menus like
  a sane person.


  Anyway, some documentation:

  Most of this file is copied from MenuColumn.qml. Believe
  it or not, this serves a purpose other than to make your
  life into a living nightmare as you try to identify even
  a single root cause for a bug through the mess that is
  this menu system.

  MenuColumn.qml has a parent with visible:false. This is
  because the parent is being rendered through an
  OpacityMask to properly round the corners. When a
  MouseArea is non-visible or has a non-visible parent, it
  refuses to propagate any mouse events. This means that I
  must defy all logic and reason and structure the mouse
  areas in a seperate tree.

  I tried my best to do some hacky coupling between
  parameters, but it didn't really work.


  THE POINT OF ALL THIS:
  If you make changes to MenuColumn, you *must* copy them
  here. The structure is one-to-one, though some content
  from MenuColumn has been omitted.

  Good luck.
*/

import QtQuick 2.13

import "../Global"

Column {
    property var columnItems
    property real biggestItemWidth: -1
    property int startIndex: 0
    width: {
        if (minWidth && biggestItemWidth < minWidth) {
            return minWidth;
        }
        else if (maxWidth && biggestItemWidth > maxWidth) {
            return maxWidth;
        }
        else {
            return biggestItemWidth;
        }
    }

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

        Item {
            width: parent.width
            height: modelData.separator ? 7 : 21

            // This is used for calculating what the text
            // width would be if there were no max width
            Text {
                visible: false

                onWidthChanged: {
                    let menuItemWidth = width + 14 + shortcutText.width + (modelData.shortcut ? 14 : 0) + (columnItems[index].submenu ? 14 : 0);
                    if (menuItemWidth > biggestItemWidth) {
                        biggestItemWidth = menuItemWidth;
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

                visible: false

                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 0
                anchors.rightMargin: modelData.submenu ? 7 : 0
                anchors.right: parent.right
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 9
                text: modelData.shortcut ? modelData.shortcut : ""
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                propagateComposedEvents: true
                onEntered: {
                    selectedIndex = index + startIndex;
                    attemptedSelectedIndex = index + startIndex;

                    Anthem.displayStatusMessage(modelData.hoverText ? modelData.hoverText : '');

                    if (openedSubmenuIndex > -1 && !blockSubmenuClose) {
                        closeSubmenus(id);
                        openedSubmenuIndex = -1;
                    }

                    if (modelData.separator || modelData.disabled) {
                        return;
                    }

                    if (columnItems[index].submenu) {
                        openSubmenuAt(index + startIndex, 500);
                    }
                }
                onPressed: {
                    if (columnItems[index].separator || columnItems[index].disabled) {
                        return;
                    }

                    if (menuItems[index + startIndex].onTriggered) {
                        menuItems[index + startIndex].onTriggered();
                    }
                    if (columnItems[index].submenu) {
                        openSubmenuAt(index + startIndex);
                    }
                    else
                        closeAll();
                }
            }
        }
    }
}
