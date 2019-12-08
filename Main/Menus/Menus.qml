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

Item {
    id: menuContainer
    property Component menuComponent

    property var _idCounter: 0

    property int openMenuCount: 0

    /*
        Below is the expected structure for props.
        All keys are optional.

        {
            altX: real,
            altY: real,
            openLeft: bool,
            autoWidth: bool,
            minWidth: real,
            maxWidth: real,
            maxHeight: real
        }
    */
    function open(x, y, menuItems, props) {
        if (props.altX === undefined)
            props.altX = x;
        if (props.altY === undefined)
            props.altY = y;

        if (menuComponent === null)
            menuComponent = Qt.createComponent("MenuSingleton.qml");

        if (menuComponent.status === Component.Ready) {
            let options = {
                id: _idCounter,
                x: x,
                y: y,
                alternateX: props.altX,
                alternateY: props.altY,
                openLeft: props.openLeft,
//                width: props.menuWidth,
                autoWidth: props.autoWidth,
                minWidth: props.minWidth,
                maxWidth: props.maxWidth,
                maxHeight: props.maxHeight,
                menuItems: menuItems,
            }

            let menu = menuComponent.createObject(menuContainer, options);
            menu.closeAll.connect(() => {
                closeAll();
            });
            menu.openSubmenu.connect((x, y, items, props) => {
                open(x, y, items, props);
            });
            menu.closeSubmenus.connect((id) => {
                closeAfter(id);
            });
            menu.closeThis.connect((id) => {
                closeAfter(id);
                closeAt(id);
            });
            _idCounter++;
            openMenuCount++;
            return _idCounter - 1;
        }
        else if (menuComponent.status === Component.Error) {
            console.error("Error loading component:", menuComponent.errorString());
        }
        else {
            console.error("menuComponent.status is not either \"ready\" or \"error\". This may mean the component hasn't loaded yet. This shouldn't be possible.");
        }
        return -1;
    }

    function closeAt(id) {
        let previousChild = undefined;
        for (let i = 1; i < children.length; i++) {
            if (children[i].id === id) {
                children[i].destroy();
                openMenuCount--;
                if (previousChild !== undefined) {
                    previousChild.openedSubmenuIndex = -1;
                }

                return id;
            }
            previousChild = children[i]
        }

        return -1;
    }

    function closeAfter(id) {
        let destroyStarted = false;
        let previousChild = undefined;

        for (let i = 1; i < children.length; i++) {
            if (children[i].id === id) {
                destroyStarted = true;
                if (previousChild !== undefined) {
                    previousChild.openedSubmenuIndex = -1;
                }
            }
            else if (destroyStarted) {
                children[i].destroy();
                openMenuCount--;
            }
            else {
                previousChild = children[i]
            }
        }

        if (openMenuCount < 0)
            openMenuCount = 0;
    }

    function closeAll() {
        for (let i = 1; i < children.length; i++) {
            children[i].destroy();
            openMenuCount--;
        }

        if (openMenuCount < 0)
            openMenuCount = 0;
    }

    function closeLast() {
        children[children.length - 1].destroy();
        openMenuCount--;
    }

    MouseArea {
        id: mouseArea
        anchors.fill: openMenuCount > 0 ? parent : undefined
        width: openMenuCount < 1 ? 0 : undefined
        height: openMenuCount < 1 ? 0 : undefined

        onPressed: {
            closeAll();
        }
    }
}
