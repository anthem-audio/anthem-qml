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
    property int startWidth
    property int startHeight
    property int startWindowX
    property int startWindowY
    property var startMousePos

    MouseHelper {
        id: mouseHelper
    }

    function doOnPress() {
        startWidth = window.width;
        startHeight = window.height;
        startWindowX = window.x;
        startWindowY = window.y;
        startMousePos = mouseHelper.getCursorPosition();
    }

    // Resize right
    MouseArea {
        width: 5

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        cursorShape: Qt.SizeHorCursor

        onPressed: doOnPress()

        onMouseXChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            window.width = startWidth + currentMousePos.x - startMousePos.x;
        }
    }

    // Resize top
    MouseArea {
        height: 5
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        cursorShape: Qt.SizeVerCursor

        onPressed: doOnPress()

        onMouseYChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            let newY = startWindowY + currentMousePos.y - startMousePos.y;
            window.y = newY;
            window.height = startHeight - (newY - startWindowY);
        }
    }

    // Resize bottom
    MouseArea {
        height: 5
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        cursorShape: Qt.SizeVerCursor

        onPressed: doOnPress()

        onMouseYChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            window.height = startHeight + currentMousePos.y - startMousePos.y;
        }
    }

    // Resize left
    MouseArea {
        width: 5
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        cursorShape: Qt.SizeHorCursor

        onPressed: doOnPress()

        onMouseXChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            let newX = startWindowX + currentMousePos.x - startMousePos.x;
            window.x = newX;
            window.width = startWidth - (newX - startWindowX);
        }
    }

    // Resize top-left
    MouseArea {
        anchors.top: parent.top
        anchors.left: parent.left
        width: 10
        height: 10

        cursorShape: Qt.SizeFDiagCursor

        onPressed: doOnPress()

        onPositionChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();

            let newY = startWindowY + currentMousePos.y - startMousePos.y;
            window.y = newY;
            window.height = startHeight - (newY - startWindowY);

            let newX = startWindowX + currentMousePos.x - startMousePos.x;
            window.x = newX;
            window.width = startWidth - (newX - startWindowX);
        }
    }

    // Resize top-right
    MouseArea {
        anchors.top: parent.top
        anchors.right: parent.right
        width: 10
        height: 10

        cursorShape: Qt.SizeBDiagCursor

        onPressed: doOnPress()

        onPositionChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            window.width = startWidth + currentMousePos.x - startMousePos.x;
            let newY = startWindowY + currentMousePos.y - startMousePos.y;
            window.y = newY;
            window.height = startHeight - (newY - startWindowY);
        }
    }

    // Resize bottom-left
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 10
        height: 10

        cursorShape: Qt.SizeBDiagCursor

        onPressed: doOnPress()

        onPositionChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            let newX = startWindowX + currentMousePos.x - startMousePos.x;
            window.x = newX;
            window.width = startWidth - (newX - startWindowX);
            window.height = startHeight + currentMousePos.y - startMousePos.y;
        }
    }

    // Resize bottom-right
    MouseArea {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 10
        height: 10

        cursorShape: Qt.SizeFDiagCursor

        onPressed: doOnPress()

        onPositionChanged: {
            let currentMousePos = mouseHelper.getCursorPosition();
            window.width = startWidth + currentMousePos.x - startMousePos.x;
            window.height = startHeight + currentMousePos.y - startMousePos.y;
        }
    }
}
