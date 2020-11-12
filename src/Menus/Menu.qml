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

import QtQuick 2.14

/*
    This represents a styled menu in Anthem. This includes
    right-click menus, the file menu, and any other popup
    list that can be requested by the UI.
*/

Item {
    id: menu

    property var menuItems
    visible: false
    property real menuX: 0
    property real menuY: 0
    property bool autoWidth: true
    property var minWidth
    property var maxWidth
    property var maxHeight

    function open() {
        if (menuHelper.openMenuCount > 0)
            return;

        let mouseGlobal = mapToGlobal(menuX, menuY);
        let windowGlobal = menuHelper.mapToGlobal(0, 0);

        menuHelper.open(
                    mouseGlobal.x - windowGlobal.x,
                    mouseGlobal.y - windowGlobal.y,
                    menuItems,
                    {
                        autoWidth: autoWidth,
                        minWidth: minWidth,
                        maxWidth: maxWidth,
                        maxHeight: maxHeight
                    });
    }
}
