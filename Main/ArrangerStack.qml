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
    property int _patternEditorWidthOld: -1
    property int minPatternEditorWidth: 200
    property int minArrangerWidth: 200

    Rectangle {
        id: patternEditor
        color: Qt.rgba(1, 0, 0, 0.02)
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        width: patternEditorWidth
        visible: showHidePatternEditorBtn.pressed
    }

    Rectangle {
        id: leftBorder
        width: showHidePatternEditorBtn.pressed ? 3 : 0
        visible: showHidePatternEditorBtn.pressed
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
        color: Qt.rgba(0, 1, 0, 0.02)

        anchors {
            top: parent.top
            left: leftBorder.right
            bottom: parent.bottom
        }
        width: showHidePatternPickerBtn.pressed ? 145 : 0
        visible: showHidePatternPickerBtn.pressed
    }

    Rectangle {
        id: rightBorder
        width: showHidePatternPickerBtn.pressed ? 3 : 0
        visible: showHidePatternPickerBtn.pressed
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

    // Show/hide buttons
    Button {
        id: showHidePatternEditorBtn
        anchors {
            bottom: parent.bottom
            left: parent.left
            bottomMargin: 3
            leftMargin: 3
        }
        width: 20
        height: 20
        isToggleButton: true
        pressed: true

        imageSource: "Images/Pattern Editor.svg"
        imageWidth: 11
        imageHeight: 11

        onPressedChanged: {
            if (pressed) {
                patternEditorWidth = _patternEditorWidthOld;
            }
            else {
                _patternEditorWidthOld = patternEditorWidth;
                patternEditorWidth = 0;
            }
        }

        hoverMessage: pressed ? "Hide pattern editor" : "Show pattern editor"
    }

    Button {
        id: showHidePatternPickerBtn
        anchors {
            bottom: parent.bottom
            left: showHidePatternEditorBtn.right
            bottomMargin: 3
            leftMargin: 2
        }
        width: 20
        height: 20
        isToggleButton: true
        pressed: true

        imageSource: "Images/Pattern Picker.svg"
        imageWidth: 12
        imageHeight: 11

        hoverMessage: pressed ? "Hide pattern picker" : "Show pattern picker"
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
                showHidePatternEditorBtn.pressed
                let newPatternEditorWidth = _startWidth + mouse.x - _startX;
                let currentMaxPatternEditorWidth = parent.width - minArrangerWidth - 145 - 6;
                let actualNewValue;
                if (newPatternEditorWidth < minPatternEditorWidth) {
                    actualNewValue = minPatternEditorWidth;
                }
                else if (newPatternEditorWidth > currentMaxPatternEditorWidth) {
                    actualNewValue = currentMaxPatternEditorWidth;
                }
                else {
                    actualNewValue = newPatternEditorWidth;
                }

                let overshoot = newPatternEditorWidth - actualNewValue;

                if (overshoot < -minPatternEditorWidth * 0.5 && showHidePatternEditorBtn.pressed) {
                    showHidePatternEditorBtn.pressed = false;
                }
                else if (overshoot > -minPatternEditorWidth * 0.5 && !showHidePatternEditorBtn.pressed)
                    showHidePatternEditorBtn.pressed = true;

                patternEditorWidth = showHidePatternEditorBtn.pressed ? actualNewValue : 0;
            }
        }
        propagateComposedEvents: true
    }
}
