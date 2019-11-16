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
import QtQuick.Controls 2.13
import "BasicComponents"

Item {
    property int patternEditorWidth: 300
    property int minPatternEditorWidth: 200
    property int minArrangerWidth: 200

    Rectangle {
        id: patternEditor
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 500
        color: Qt.rgba(1, 0, 0, 0.02)
        SplitView.fillWidth: true
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: patternEditorWidth
    }

    Rectangle {
        id: leftBorder
        width: 3
        height: this.height

        anchors {
            top: parent.top
            left: patternEditor.right
            bottom: parent.bottom
        }

        color: Qt.rgba(1, 1, 1, 0.2)

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SplitHCursor
            hoverEnabled: true
            onEntered: {
                _isMouseOverResizeHandle = true;
            }
            onExited: {
                _isMouseOverResizeHandle = false;
            }
        }
    }

    Rectangle {
        id: patternPicker
        width: 145
        color: Qt.rgba(0, 1, 0, 0.02)

        anchors {
            top: parent.top
            left: leftBorder.right
            bottom: parent.bottom
        }
    }

    Rectangle {
        id: rightBorder
        width: 3
        height: this.height

        anchors {
            top: parent.top
            left: patternPicker.right
            bottom: parent.bottom
        }

        color: Qt.rgba(1, 1, 1, 0.2)

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.SplitHCursor
            hoverEnabled: true
            onEntered: {
                _isMouseOverResizeHandle = true;
            }
            onExited: {
                _isMouseOverResizeHandle = false;
            }
        }
    }

    Rectangle {
        color: Qt.rgba(0, 0, 1, 0.02)

        anchors {
            top: parent.top
            left: rightBorder.right
            bottom: parent.bottom
            right: parent.right
        }
    }

    property bool _isMouseOverResizeHandle: false
    property bool _isDragActive: false
    property int _startWidth: -1
    property int _startX: -1

    MouseArea {
        id: bigMouseArea
        anchors.fill: parent
        cursorShape: pressed ? Qt.SplitHCursor : undefined
        onPressed: {
            if (!_isMouseOverResizeHandle) {
                mouse.accepted = false;
            }
            else {
                _startWidth = patternEditorWidth;
                _startX = mouse.x;
                _isDragActive = true;
            }
        }
        onReleased: {
            _isDragActive = false;
        }
        onPositionChanged: {
            if (_isDragActive) {
                let newPatternEditorWidth = _startWidth + mouse.x - _startX;
                let currentMaxPatternEditorWidth = parent.width - minArrangerWidth - 145 - 6;
                if (newPatternEditorWidth < minPatternEditorWidth) {
                    patternEditorWidth = minPatternEditorWidth;
                }
                else if (newPatternEditorWidth > currentMaxPatternEditorWidth) {
                    patternEditorWidth = currentMaxPatternEditorWidth;
                }
                else {
                    patternEditorWidth = newPatternEditorWidth;
                }
            }
        }
        propagateComposedEvents: true
    }
}
