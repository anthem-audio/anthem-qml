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

import "GenericTooltip"

TooltipWrapper {
    property int instanceID
    property var pickerInstance
    property string hoverColor

    function setHoverColor(color) {
        hoverColor = color;
    }

    onOpened: {
        instanceID = id;
        pickerInstance = tooltipManager.get(id);
        pickerInstance.children[1] // ColorPicker
            .colorHovered.connect(setHoverColor);
    }

    content: Item {
        property int id

        width: 280
        height: 102

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Qt.rgba(0, 0, 0, 0.72)
        }

        ColorPicker {
            id: picker
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 6
        }
    }
}
