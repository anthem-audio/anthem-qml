/*
    Copyright (C) 2019, 2020 Joshua Wade

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

import QtQuick 2.15
import QtGraphicalEffects 1.15
import '../Global'

// See pinned messages for hover styles

Item {
    id: button

    // Used to describe the visual state of the button
    enum State {
        Inactive,
        Hovered,
        Highlighted, // currently only used for tabs
        Pressed,
        Active,      // for toggle buttons
        Disabled
    }

    property bool   showBackground: true
    property bool   pressed: false
    property bool   isToggleButton: false
    property bool   isHighlighted: false
    property bool   isDisabled: false
    property bool   allowPressEventsOnDisable: false
    property real   margin: 5
    property string hoverMessage: ''

    onHoverMessageChanged: {
        if (mouseArea.hoverActive) {
            globalStore.statusMessage = hoverMessage;
        }
    }

    property string imageSource: ''
    property real   imageWidth
    property real   imageHeight

    property string textContent: ''
    property string textFloat: 'center'
    property real   textPixelSize: 11
    property bool   textAutoWidth: false
    property bool   isMouseDown: false

    property bool   clickOnMouseDown: false
    property bool   repeatOnHold: false

    readonly property real textWidth: text.width

    property alias hovered: buttonProps.isHoverActive

    width: textAutoWidth ? text.width + margin * 2 + 3 : undefined

    function calculateWidth() {
        if (textAutoWidth) {
            width = text.width + margin * 2 + 3;
        }
    }

    Component.onCompleted: calculateWidth()
    onMarginChanged: calculateWidth()

    function getState() {
        if (isDisabled) {
            return Button.State.Disabled;
        }
        else if (isHighlighted) {
            return Button.State.Highlighted;
        }
        else if (button.isMouseDown) {
            return Button.State.Pressed;
        }
        else if (isToggleButton && pressed) {
            if (isToggleButton && !showBackground) {
                return Button.State.Highlighted;
            }
            else {
                return Button.State.Active;
            }
        }
        else if (hovered) {
            return Button.State.Hovered;
        }
        else {
            return Button.State.Inactive;
        }
    }

    property int    state: getState()

    QtObject {
        id: buttonProps
        property bool isHoverActive: false
        property real hue: 162 / 360 // change to be dynamic based on user settings

        function getContentColor() {
            switch (button.state) {
            case Button.State.Inactive:
                return Qt.hsla(0, 0, 1, 1); // 70% opacity white
            case Button.State.Hovered:
                return Qt.hsla(0, 0, 1, 1); // 80% opacity white
            case Button.State.Highlighted:
                return colors.main
            case Button.State.Pressed:
                return Qt.hsla(0, 0, 1, 1); // 70% opacity white
            case Button.State.Active:
                return Qt.hsla(0, 0, 0, 1); // 60% opacity black
            case Button.State.Disabled:
                return Qt.hsla(0, 0, 1, 1) // 25% opacity white
            }
        }

        property color contentColor: getContentColor()

        function getContentOpacity() {
            switch (button.state) {
            case Button.State.Inactive:
                return 0.7; // 70% opacity white
            case Button.State.Hovered:
                return 0.8; // 80% opacity white
            case Button.State.Highlighted:
                return 1; // #37a483 (+ hue shift)
            case Button.State.Pressed:
                return 0.6; // #37a483 (+ hue shift), 50% opacity
            case Button.State.Active:
                return 0.6; // 60% opacity black
            case Button.State.Disabled:
                return 0.25 // 25% opacity white
            }
        }

        property real contentOpacity: getContentOpacity()
    }

    signal clicked()

    Timer {
        id: repeatTimer
        interval: 100; repeat: true
        onTriggered: clicked()
    }

    Timer {
        id: repeatStartTimer
        interval: 200; repeat: false
        onTriggered: repeatTimer.start()
    }

    Rectangle {
        id: inside

        visible: showBackground
        anchors.fill: parent
        radius: 2

        QtObject {
            id: insideProps

            function getOpacity() {
                switch (button.state) {
                case Button.State.Inactive:
                    return 0; // transparent
                case Button.State.Hovered:
                    return 0.12; // 12% opacity white
                case Button.State.Highlighted:
                    return 0.09; // 9% opacity white
                case Button.State.Pressed:
                    return 0.09; // #37a483 (+ hue shift), 50% opacity
                case Button.State.Active:
                    return 1; // #37a483 (+ hue shift)
                case Button.State.Disabled:
                    return 0.04 // 4% opacity white
                }
            }

            property real opacity: getOpacity()

            function getColor() {
                switch (button.state) {
                case Button.State.Inactive:
                    return Qt.hsla(0, 0, 1, 1); // transparent
                case Button.State.Hovered:
                    return Qt.hsla(0, 0, 1, 1); // 12% opacity white
                case Button.State.Highlighted:
                    return Qt.hsla(0, 0, 0, 1); // transparent
                case Button.State.Pressed:
                    return Qt.hsla(0, 0, 1, 1); // 9% opacity white
                case Button.State.Active:
                    return colors.main
                case Button.State.Disabled:
                    return Qt.hsla(0, 0, 1, 1); // 4% opacity white
                }
            }

            property color color: getColor()
        }

        color: insideProps.color
        opacity: insideProps.opacity
    }

    Text {
        id: text
        text: qsTr(textContent)
        font.family: Fonts.mainRegular.name
        font.pixelSize: textPixelSize
        anchors.centerIn: textFloat == 'center' ? parent : undefined
        anchors.left: textFloat == 'left' ? parent.left : undefined
        anchors.right: textFloat == 'right' ? parent.right : undefined
        anchors.verticalCenter: textFloat == 'left' || textFloat == 'right' ? parent.verticalCenter : undefined
        anchors.margins: 4
        property int colorVal: isToggleButton && pressed ? 0 : 1
        color: buttonProps.contentColor
        opacity: buttonProps.contentOpacity

        onWidthChanged: parent.calculateWidth()
    }

    Image {
        id: icon
        // If the source is defined, use it. Otherwise, use a transparent 1-pixel PNG.
        source: imageSource != '' ? '../' + imageSource : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
        width: imageWidth
        height: imageHeight
        anchors.centerIn: parent
        sourceSize.width: imageWidth
        sourceSize.height: imageHeight
        visible: false
    }
    ColorOverlay {
        anchors.fill: icon
        source: icon
        property int colorVal: isToggleButton && pressed ? 0 : 1
        visible: true;
        color: buttonProps.contentColor
        opacity: buttonProps.contentOpacity
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        propagateComposedEvents: true

        onClicked: {
            if (isDisabled && !allowPressEventsOnDisable)
                return;
            if (clickOnMouseDown)
                return;
            button.clicked();
        }

        onPressed: {
            if (!isToggleButton)
                button.pressed = true;
            button.isMouseDown = true;
            if (clickOnMouseDown) button.clicked();
            if (repeatOnHold) {
                repeatStartTimer.start();
            }
        }

        onReleased: {
            if (!isToggleButton)
                button.pressed = false;
            else
                button.pressed = !button.pressed;
            button.isMouseDown = false;
            if (repeatOnHold) {
                repeatStartTimer.stop();
                repeatTimer.stop();
            }
        }

        hoverEnabled: true
        onEntered: {
            hovered = true;
            if (hoverMessage !== '')
                globalStore.statusMessage = hoverMessage;
        }
        onExited: {
            hovered = false;
            globalStore.statusMessage = '';
        }
    }
}
