/*
    Copyright (C) 2020 Joshua Wade

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

Item {
    property Component content
    property int id
    property bool isOpen: false

    Connections {
        target: tooltipManager
        onTooltipClosed: {
            if (tooltipId === id) {
                isOpen = false;
            }
        }
    }

    function open() {
        let pos = mapToGlobal(0, 0);
        let windowPos = tooltipManager.mapToGlobal(0, 0);
        id = tooltipManager.open(
            content,
            pos.x - windowPos.x,
            pos.y - windowPos.y
        );
    }

    function close() {
        tooltipManager.close(id);
    }
}
