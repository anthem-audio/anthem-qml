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
    ButtonGroup uses a Flow layout to arrange buttons
    in a group. It is driven by a ListModel and it
    automatically takes care of displaying the
    buttons and drawing the correct borders. It can
    also optionally make the buttons behave as a
    coherent tab group with
        managementType: ButtonGroup.ManagementType.Selector

    When this property is set, selectedIndex is equal
    to the index of the selected button, or -1 if there
    is no selected button. selectedIndex can also be set
    externally. If allowDeselection is set to true, then
    the selected button can be clicked to deselect it.
    When this happens, selectedIndex will be set to -1.

    Example model structure below.
    If a property is not given, the default will be used.

    ButtonGroup {
        // General properties and button defaults here...
        ListModel {
            id: myModel
            ListElement {
                autoWidth:      (boolean)
                buttonWidth:    (real)
                buttonHeight:   (real)
                leftMargin:     (real)
                topMargin:      (real)
                textContent:    (string)
                innerMargin:    (real)
                imageWidth:     (real)
                imageHeight:    (real)
                imageSource:    (string)
                hoverMessage:   (string)
                isToggleButton: (boolean)
                onPress:        (function, () => {} or function() {})
            }
            ListElement {
                //...
            }
            ListElement {
                //...
            }
        }
        model: myModel
    }
*/

Item {
    id: buttonGroup
    property var  buttons: []

    property int  managementType: ButtonGroup.ManagementType.None
    property int  selectedIndex: -1
    property bool allowDeselection: false

    property bool showBackground: true

    property real defaultButtonWidth
    property real defaultButtonHeight
    property real defaultImageWidth: defaultButtonWidth
    property real defaultImageHeight: defaultButtonHeight
    property real defaultLeftMargin
    property real defaultTopMargin
    property real defaultInnerMargin

    property bool buttonAutoWidth: false
    property bool fixedWidth: true

    property int  _oldSelectedIndex: selectedIndex

    width: fixedWidth ? undefined : contentSpacer.width
    height: defaultButtonHeight

    onSelectedIndexChanged: {
        if (repeater.itemAt(0) === null) {
            return;
        }

        if (_oldSelectedIndex > -1) {
            repeater.itemAt(_oldSelectedIndex).children[2].pressed = false;
        }
        if (selectedIndex > -1) {
            repeater.itemAt(selectedIndex).children[2].pressed = true;
        }

        _oldSelectedIndex = selectedIndex;
    }

    enum ManagementType {
        None,
        Selector
    }

    Rectangle {
        id: contentSpacer
        anchors.fill: fixedWidth ? parent : undefined
        anchors.top: fixedWidth ? undefined : parent.top
        anchors.bottom: fixedWidth ? undefined : parent.bottom
        anchors.left: fixedWidth ? undefined : parent.left
        width: fixedWidth ? undefined : flow.width + flow.anchors.leftMargin + flow.anchors.rightMargin
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: showBackground ? 1 : 0
        radius: 2
        color: "transparent"
        Flow {
            id: flow
            anchors.fill: fixedWidth ? parent : undefined
            anchors.top: fixedWidth ? undefined : parent.top
            anchors.left: fixedWidth ? undefined : parent.left
            anchors.bottom: fixedWidth ? undefined : parent.bottom
            anchors.topMargin: showBackground ? 1 : 0
            anchors.bottomMargin: showBackground ? 1 : 0
            anchors.leftMargin: showBackground ? 1 : 0
            anchors.rightMargin: showBackground ? 1 : 0
            Repeater {
                id: repeater
                anchors.fill: parent
                model: buttonGroup.buttons
                Item {
                    id: btnContainer

                    QtObject {
                        id: props
                        property var _autoWidth: typeof autoWidth !== 'undefined' ? autoWidth : undefined
                        property var _buttonWidth: typeof buttonWidth !== 'undefined' ? buttonWidth : undefined
                        property var _buttonHeight: typeof buttonHeight !== 'undefined' ? buttonHeight : undefined
                        property var _leftMargin: typeof leftMargin !== 'undefined' ? leftMargin : undefined
                        property var _topMargin: typeof topMargin !== 'undefined' ? topMargin : undefined
                        property var _textContent: typeof textContent !== 'undefined' ? textContent : undefined
                        property var _innerMargin: typeof innerMargin !== 'undefined' ? innerMargin : undefined
                        property var _imageWidth: typeof imageWidth !== 'undefined' ? imageWidth : undefined
                        property var _imageHeight: typeof imageHeight !== 'undefined' ? imageHeight : undefined
                        property var _imageSource: typeof imageSource !== 'undefined' ? imageSource : undefined
                        property var _hoverMessage: typeof hoverMessage !== 'undefined' ? hoverMessage : undefined
                        property var _isToggleButton: typeof isToggleButton !== 'undefined' ? isToggleButton : undefined
                        property var _onPress: typeof onPress !== 'undefined' ? onPress : undefined
                        property int _leftBorderWidth: !showBackground || btnContainer.x - flow.x <= 1 ? 0 : 1
                        property int _topBorderHeight: !showBackground || btnContainer.y - flow.y <= 1 ? 0 : 1
                        property var _calculatedWidth: !buttonAutoWidth ? (_buttonWidth || defaultButtonWidth) - 2 + _leftBorderWidth : undefined
                        property var _calculatedHeight: (_buttonHeight || defaultButtonHeight) - 2 + _topBorderHeight
                    }

                    width: {
                        let baseWidth;

                        if (props._autoWidth || (props._autoWidth === undefined && buttonAutoWidth)) {
                            baseWidth = btn.width;
                        }
                        else {
                            baseWidth = props._calculatedWidth;
                        }

                        return baseWidth + (props._leftMargin || defaultLeftMargin || 0) + props._leftBorderWidth
                    }
                    height:   (props._calculatedHeight)
                            + (props._topMargin || defaultTopMargin || 0)
                            + props._topBorderHeight

                    Rectangle {
                        id: leftBorder
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: props._leftBorderWidth
                        color: Qt.rgba(0, 0, 0, 0.4)
                    }

                    Rectangle {
                        id: topBorder
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: props._topBorderHeight
                        color: Qt.rgba(0, 0, 0, 0.4)
                        anchors.leftMargin: props._leftBorderWidth != 0 && props._topBorderHeight != 0 ? 1 : 0
                    }

                    Button {
                        id: btn
                        anchors.left: leftBorder.right
                        anchors.top: topBorder.bottom
                        width: props._autoWidth ? undefined : props._calculatedWidth

                        textAutoWidth: props._autoWidth || buttonAutoWidth || false

                        height: props._calculatedHeight

                        anchors.leftMargin: props._leftMargin || defaultLeftMargin || 0

                        anchors.topMargin: props._topMargin || defaultTopMargin || 0

                        textContent: props._textContent || ""
                        margin: props._innerMargin || defaultInnerMargin
                        isToggleButton: props._isToggleButton || managementType === ButtonGroup.ManagementType.Selector
                        pressed: index == selectedIndex
                        showBackground: buttonGroup.showBackground
                        showBorder: false

                        imageWidth: props._imageWidth || defaultImageWidth
                        imageHeight: props._imageHeight || defaultImageHeight
                        imageSource: props._imageSource || ""

                        hoverMessage: props._hoverMessage || ""

                        onPress: {
                            if (props._onPress !== undefined)
                                props._onPress();
                        }
                    }

                    MouseArea {
                        anchors.fill: btn
                        onPressed: {
                            if (managementType === ButtonGroup.ManagementType.None) {
                                mouse.accepted = false;
                            }
                            else if (managementType === ButtonGroup.ManagementType.Selector) {
                                if ((!btn.pressed && !allowDeselection) || allowDeselection) {
                                    btn.isMouseDown = true;
                                }
                            }
                        }

                        onReleased: {
                            if (managementType === ButtonGroup.ManagementType.Selector) {
                                btn.isMouseDown = false;
                            }
                        }

                        onClicked: {
                            if (managementType === ButtonGroup.ManagementType.None) {
                                mouse.accepted = false;
                            }
                            else if (managementType === ButtonGroup.ManagementType.Selector) {
                                if (selectedIndex == index && allowDeselection)
                                    selectedIndex = -1;
                                else
                                    selectedIndex = index;
                            }
                        }
                    }
                }
            }
        }
    }
}
