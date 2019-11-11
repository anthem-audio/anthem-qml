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

Item {
    property var window
    property int margin: 5

    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 28 + 26 + 28 + margin // close buttons width + margin

        onPressed: {
            previousX = mouseX
            previousY = mouseY
        }

        onReleased: {
            if (window.y + mouseY < 1) {
                window.isMaximized = true;
                window.showMaximized();
            }
        }

        onMouseXChanged: {
            if (window.isMaximized) {
                window.isMaximized = false;
                window.showNormal();
            }

            var dx = mouseX - previousX
            window.setX(window.x + dx)
        }

        onMouseYChanged: {
            if (window.isMaximized) {
                window.isMaximized = false;
                window.showNormal();
            }

            var dy = mouseY - previousY
            window.setY(window.y + dy)
        }
    }
}
