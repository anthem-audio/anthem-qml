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
import io.github.anthem.utilities.mousehelper 1.0

Item {
    property var window
    property int margin: 5
    property int offsetX
    property int offsetY

    MouseHelper {
        id: mouseHelper
    }

    MouseArea {
        anchors.fill: parent

        onPressed: {
            offsetX = mouse.x
            offsetY = mouse.y
        }

        onReleased: {
            if (window.y + mouseY < 1) {
                window.isMaximized = true;
                window.showMaximized();
            }
        }

        onPositionChanged: {
            if (window.isMaximized) {
                window.isMaximized = false;
                window.showNormal();
            }

            let globalMousePosition = mouseHelper.getCursorPosition();

            var newX = globalMousePosition.x - offsetX
            var newY = globalMousePosition.y - offsetY
            window.setX(newX);
            window.setY(newY);
        }
    }
}
