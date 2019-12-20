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
 * This class has duplicate components that
 * separately deal with menu rendering and MouseArea
 * positioning. This is because the visible part of
 * the menu has visible: false and is instead
 * rendered through an OpacityMask, this to round the
 * corners of highlighted menu items properly.
 * MouseAreas contained in a non-visible component do
 * not work, so the MouseAreas must be positioned in a
 * separate component. This is not optimal, but it
 * seems to be unavoidable.
 *
 * This code is bad and I am so very sorry to whoever
 * has to read it in the future.
 *
 * IMPORTANT:
 * If you change selectedIndex, you must also change
 * attemptedSelectedIndex! If you don't, when you
 * a submenu open, it will close after 1 second due
 * to how I'm handling mouse interaction UX.
 */

Item {
    property var menuItems
    property var _processedMenuItems
    property int _ignoredItemsCount: menuItems.filter(item => item.separator || item.disabled || item.newColumn).length
    property int selectedIndex: -1
    property int attemptedSelectedIndex: -1
    property real hue: 162 / 360
    property int id
    property int openedSubmenuIndex: -1
    property bool blockSubmenuClose: false
    property real currentSubmenuX
    property real currentSubmenuY
    property real currentSubmenuAltX
    property real currentSubmenuAltY
    property real alternateX
    property real alternateY
    property bool openLeft
    property bool autoWidth
    property var minWidth
    property var maxWidth
    property var maxHeight
    property var _keymap
    signal closeAll()
    signal closeThis(int id)
    signal closeSubmenus(int id)
    signal moveMouseToSubmenu(int id)
    signal openSubmenu(real x, real y, var items, var props)

    width: menuContent.width
    height: menuContent.height

    Component.onCompleted: {
        // This breaks up the single list of menu items into
        // multiple column lists.
        let runningHeight = 0;
        let columnLists = [[]]

        for (let menuItem of menuItems) {
            if (runningHeight > maxHeight || menuItem.newColumn === true) {
                columnLists.push([]);
                runningHeight = 0;
                if (menuItem.newColumn === true) {
                    continue;
                }
            }
            runningHeight += menuItem.separator ? 7 : 21;
            columnLists[columnLists.length - 1].push(menuItem);
        }

        if (columnLists[columnLists.length - 1].length === 0) {
            columnLists.pop();
        }

        _processedMenuItems = columnLists;
    }

    onHeightChanged: {
        // This is my replacement for Component.onCompleted.
        // This code relies on the height of a menuContent
        // to propagate through, something that hasn't
        // happened when Component.onCompleted is fired.
        if (height > 0) {
            // Reposition menu so it's not off screen, if possible
            let windowTopLeft = mapToGlobal(parent.x, parent.y);
            let windowBottomRight = mapToGlobal(parent.x + parent.width, parent.y + parent.height);
            let bottomRight = mapToGlobal(x + width, y + height);

            if (openLeft || (windowBottomRight.x - bottomRight.x < 0)) {
                // https://stackoverflow.com/a/25910841/8166701
                [x, alternateX] = [alternateX, x];
                [y, alternateY] = [alternateY, y];
                openLeft = true;
            }

            let topLeft = mapToGlobal(x, y);

            if (topLeft.x - windowTopLeft.x < 0) {
                // https://stackoverflow.com/a/25910841/8166701
                [x, alternateX] = [alternateX, x];
                [y, alternateY] = [alternateY, y];
                openLeft = false;
            }

            if (openLeft) {
                x -= width;
            }

            moveOnScreen();

            // Set up keymap
            for (let i = 0; i < menuItems.length; i++) {
                if (menuItems[i].shortcutChar)
                    _keymap[menuItems[i].shortcutChar] = i;
            }
        }
    }

    function moveOnScreen() {
        let windowTopLeft = mapToGlobal(parent.x, parent.y);
        let windowBottomRight = mapToGlobal(parent.x + parent.width, parent.y + parent.height);
        let topLeft = mapToGlobal(x, y);
        let bottomRight = mapToGlobal(x + width, y + height);

        let distanceFromLeft = topLeft.x - windowTopLeft.x;
        let distanceFromTop = topLeft.y - windowTopLeft.y;
        let distanceFromRight = windowBottomRight.x - bottomRight.x;
        let distanceFromBottom = windowBottomRight.y - bottomRight.y;

        if (distanceFromLeft < 0)
            x += -distanceFromLeft;
        if (distanceFromTop < 0)
            y += -distanceFromTop;
        if (distanceFromRight < 0)
            x += distanceFromRight;
        if (distanceFromBottom < 0)
            y += distanceFromBottom;
    }

    onMenuItemsChanged: {
        if (_keymap === undefined) {
            _keymap = {};
        }

        // Process underline shortcut indicators
        for (let i = 0; i < menuItems.length; i++) {
            if (menuItems[i].text === undefined)
                continue;
            let text = menuItems[i].text;
            let underscoreIndex = text.search('_');
            if (underscoreIndex < 1)
                continue;
            if (text[underscoreIndex - 1] === '\\') {
                menuItems[i].text = text.substring(0, underscoreIndex - 1) + text.substring(underscoreIndex);
                continue;
            }
            menuItems[i].shortcutChar = text[underscoreIndex - 1].toLowerCase();
            menuItems[i].text = text.substring(0, underscoreIndex - 1) + '<u>' + text[underscoreIndex - 1] + '</u>' + text.substring(underscoreIndex + 1);
        }
    }

    focus: openedSubmenuIndex < 0

    Keys.onPressed: {
        let chr = event.text.toLowerCase();
        if (_keymap[chr] !== undefined) {
            menuItems[_keymap[chr]].onTriggered();
            closeAll();
        }
    }

    Keys.onEnterPressed: {
        keyboardTrigger(selectedIndex);
    }

    Keys.onReturnPressed: {
        keyboardTrigger(selectedIndex);
    }

    Keys.onSpacePressed: {
        keyboardTrigger(selectedIndex);
    }

    function keyboardTrigger(index) {
        if (index < 0)
            return;
        if (menuItems[index].submenu !== undefined) {
            openSubmenuAt(index);
        }
        else {
            if (menuItems[index].onTriggered !== undefined)
                menuItems[index].onTriggered();
            closeAll();
        }
    }

    Keys.onEscapePressed: {
        closeThis(id);
    }

    Keys.onLeftPressed: {
        if (selectedIndex < 0) {
            closeThis(id);
            return;
        }

        let colIndex = getColumnIndex(selectedIndex);
        let previousColIndex = colIndex === 0 ? _processedMenuItems.length - 1 : colIndex - 1;
        let col = menuContentRepeater.itemAt(colIndex);
        let previousCol = menuContentRepeater.itemAt(previousColIndex);
        let targetItem = col.itemAt(selectedIndex - col.startIndex);
        let targetHeight = targetItem.y + targetItem.height;
        selectedIndex = getFirstIndexPastHeight(previousCol.startIndex, targetHeight);
        attemptedSelectedIndex = selectedIndex;
    }

    Keys.onRightPressed: {
        if (selectedIndex < 0) {
            selectedIndex = 0;
            attemptedSelectedIndex = selectedIndex;
            return;
        }

        if (menuItems[selectedIndex].submenu !== undefined) {
            keyboardTrigger(selectedIndex);
            return;
        }

        let colIndex = getColumnIndex(selectedIndex);
        let nextColIndex = colIndex === _processedMenuItems.length - 1 ? 0 : colIndex + 1;
        let col = menuContentRepeater.itemAt(colIndex);
        let nextCol = menuContentRepeater.itemAt(nextColIndex);
        let targetItem = col.itemAt(selectedIndex - col.startIndex);
        let targetHeight = targetItem.y + targetItem.height;
        selectedIndex = getFirstIndexPastHeight(nextCol.startIndex, targetHeight);
        attemptedSelectedIndex = selectedIndex;
    }

    function getFirstIndexPastHeight(startIndex, height) {
        let runningHeight = 0;
        for (let i = startIndex; i < menuItems.length; i++) {
            if (menuItems[i].newColumn) {
                continue;
            }
            else if (menuItems[i].separator) {
                runningHeight += 7;
            }
            else {
                runningHeight += 21;
            }
            if (height - runningHeight < 11) {
                if (menuItems[i].separator || menuItems[i].disabled) {
                    continue;
                }
                return i;
            }
        }
        return menuItems.length - 1;
    }

    Keys.onUpPressed: {
        incrementIndex(-1);
        attemptedSelectedIndex = selectedIndex;
    }

    Keys.onDownPressed: {
        incrementIndex(1);
        attemptedSelectedIndex = selectedIndex;
    }

    MouseHelper {
        id: mouseHelper
    }

    function getColumnIndex(itemIndex) {
        let columnIndex = -1;

        for (let i = menuContent.children.length - 2; i >= 0; i--) {
            let startIndex = menuContentRepeater.itemAt(i).startIndex;

            if (startIndex <= itemIndex) {
                columnIndex = i;
                break;
            }
        }

        return columnIndex;
    }

    function getColumnElement(itemIndex) {
        return menuContentRepeater.itemAt(getColumnIndex(itemIndex));
    }

    function getItemElement(index) {
        let col = getColumnElement(index);
        return col.itemAt(index - col.startIndex);
    }

    function moveMouseTo(index) {
        let selectedColumn = getColumnElement(index);
        let newSelectedElement = selectedColumn.itemAt(index - selectedColumn.startIndex);
        let newMousePos = mapToGlobal(selectedColumn.x + newSelectedElement.x + newSelectedElement.width * 0.7, newSelectedElement.y + newSelectedElement.height * 0.5);
        mouseHelper.setCursorPosition(newMousePos.x, newMousePos.y);
    }

    function openSubmenuAt(index, delay = 0) {
        let selectedColumn = getColumnElement(index);
        let selectedMenuItem = selectedColumn.itemAt(index - selectedColumn.startIndex);
        let submenuPos = mapToGlobal(selectedColumn.x + selectedMenuItem.width, selectedMenuItem.y);
        let altSubmenuPos = mapToGlobal(selectedColumn.x, selectedMenuItem.y);
        let windowPos = menuHelper.mapToGlobal(0, 0);

        currentSubmenuX = submenuPos.x - windowPos.x;
        currentSubmenuY = submenuPos.y - windowPos.y;
        currentSubmenuAltX = altSubmenuPos.x - windowPos.x;
        currentSubmenuAltY = altSubmenuPos.y - windowPos.y;

        if (delay > 0) {
            timer.setTimeout(() => {
                if (index === selectedIndex) {
                    submenuClicked(currentSubmenuX, currentSubmenuY, currentSubmenuAltX, currentSubmenuAltY, index);
                }
            }, 500);
        }
        else {
            submenuClicked(currentSubmenuX, currentSubmenuY, currentSubmenuAltX, currentSubmenuAltY, index);
        }
    }

    function submenuClicked(x, y, altX, altY, index) {
        if (openedSubmenuIndex > -1)
            return;

        // Prevent submenus from being closed when the mouse
        // moves off the submenu item
        blockSubmenuClose = true;

        // 1-second timer to remove the block set above
        timer.setTimeout(() => {
            blockSubmenuClose = false;
            if (index !== attemptedSelectedIndex) {
                selectedIndex = attemptedSelectedIndex;
                closeSubmenus(id);
                openedSubmenuIndex = -1;
                if (selectedIndex >= 0 && menuItems[selectedIndex].submenu) {
                    timer.setTimeout(() => {
                        submenuClicked(currentSubmenuX, currentSubmenuY, currentSubmenuAltX, currentSubmenuAltY, selectedIndex);
                    }, 500);
                }
            }
        }, 1000);
        openedSubmenuIndex = index;
        openSubmenu(x, y, menuItems[index].submenu, {altX: altX, altY: altY, openLeft: openLeft, menuWidth: width, autoWidth: autoWidth, minWidth: minWidth, maxWidth: maxWidth, maxHeight: maxHeight});
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

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.72)
        radius: 6
    }

    function getStartIndex(columnIndex) {
        let result = 0;
        for (let i = 0; i < columnIndex; i++) {
            result += _processedMenuItems[i].length;
            // Account for column breaks
            if (menuItems[result].newColumn === true) {
                result++;
            }
        }
        return result;
    }

    Row {
        id: menuContent
        anchors.top: parent.top
        anchors.left: parent.left

        visible: false

        Repeater {
            id: menuContentRepeater
            model: _processedMenuItems

            MenuColumn {
                columnItems: modelData
                startIndex: getStartIndex(index)
            }
        }
    }

    // direction is 1 for forward or -1 for reverse
    function incrementIndex(direction, moveMouse = false) {
        if (_ignoredItemsCount === menuItems.length)
            return;

        let tempSelectedIndex = selectedIndex;

        /*
            Yay, documentation time.

            An index of -1 represents no selected
            index. When the user presses the down
            arrow and there is no selected item,
            this code increments the index by 1 and
            voila! we're on the first menu item.
            All good so far.

            However, incrementing with a direction
            of -1 when there is no selected index
            causes the selected index to become -2,
            which then wraps around to the second-
            to-last item instead of the last item.

            The if statement below fixes that.
        */
        if (tempSelectedIndex < 0 && direction < 0) {
            tempSelectedIndex = 0;
        }

        tempSelectedIndex += direction;

        tempSelectedIndex = (tempSelectedIndex + menuItems.length) % menuItems.length;
        while (menuItems[tempSelectedIndex] !== undefined
               && (menuItems[tempSelectedIndex].separator
                   || menuItems[tempSelectedIndex].disabled
                   || menuItems[tempSelectedIndex].newColumn)) {
            tempSelectedIndex += direction;
            tempSelectedIndex = (tempSelectedIndex + menuItems.length) % menuItems.length;
        }

        selectedIndex = tempSelectedIndex;
        if (moveMouse)
            moveMouseTo(selectedIndex);
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            Anthem.displayStatusMessage('');

            if (openedSubmenuIndex > -1) {
                if (blockSubmenuClose) {
                    selectedIndex = openedSubmenuIndex;

                    // If the user moved to a submenu, make sure the
                    // blockSubmenuClose reset timer doesn't close their
                    // submenu when the timer runs out
                    attemptedSelectedIndex = selectedIndex;

                    return;
                }
                else {
                    closeSubmenus(id);
                    openedSubmenuIndex = -1;
                }
            }

            selectedIndex = -1;
        }

        onWheel: {
            if (openedSubmenuIndex > -1) {
                moveMouseToSubmenu(id);
                return;
            }

            let direction = wheel.angleDelta.y < 0 ? -1 : 1;
            incrementIndex(direction, true);
        }

        Row {
            id: menuMouseAreas

            Repeater {
                id: menuMouseAreasRepeater
                model: _processedMenuItems
                MenuColumnMouseAreas {
                    columnItems: modelData
                    startIndex: getStartIndex(index)
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
