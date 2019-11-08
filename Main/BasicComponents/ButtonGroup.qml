import QtQuick 2.13

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
        // ...
        ListModel {
            id: myModel
            ListElement {
                autoWidth:    (boolean)
                buttonWidth:  (real)
                buttonHeight: (real)
                leftMargin:   (real)
                topMargin:    (real)
                textContent:  (string)
                innerMargin:  (real)
                imageWidth:   (real)
                imageHeight:  (real)
                imagePath:    (string)
                hoverMessage: (string)
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
    property var  model: []
    property bool isSelector: false
    property bool showBackground: true
    property real defaultButtonWidth
    property real defaultButtonHeight
    property real defaultImageWidth: defaultButtonWidth
    property real defaultImageHeight: defaultButtonHeight
    property real defaultLeftMargin
    property real defaultTopMargin
    property bool buttonAutoWidth: false
    property real defaultInnerMargin
    property int  managementType: ButtonGroup.ManagementType.None
    property int  selectedIndex: -1
    property int  _oldSelectedIndex: selectedIndex
    property bool allowDeselection: false
    property bool fixedWidth: true

    width: fixedWidth ? undefined : contentSpacer.width

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
        width: fixedWidth ? undefined : flow.width
        border.color: Qt.rgba(0, 0, 0, 0.4)
        border.width: showBackground ? 1 : 0
        radius: 2
        color: "transparent"
        Flow {
            id: flow
            anchors.fill: fixedWidth ? parent : undefined
            anchors.margins: showBackground ? 1 : 0
            Repeater {
                id: repeater
                anchors.fill: parent
                model: buttonGroup.model
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
                        property var _imagePath: typeof imagePath !== 'undefined' ? imagePath : undefined
                        property var _hoverMessage: typeof hoverMessage !== 'undefined' ? hoverMessage : undefined
                        property int _leftBorderWidth: !showBackground || btnContainer.x - flow.x <= 1 ? 0 : 1
                        property int _topBorderHeight: !showBackground || btnContainer.y - flow.y <= 1 ? 0 : 1
                    }

                    width: {
                        let baseWidth;

                        if (props._autoWidth || (props._autoWidth === undefined && buttonAutoWidth)) {
                            baseWidth = btn.width;
                        }
                        else {
                            baseWidth = props._buttonWidth || defaultButtonWidth;
                        }

                        return baseWidth + (props._leftMargin || defaultLeftMargin || 0) + props._leftBorderWidth
                    }
                    height:   (props._buttonHeight || defaultButtonHeight)
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
                        width: props._autoWidth ? undefined : (props._buttonWidth || defaultButtonWidth)

                        textAutoWidth: props._autoWidth || buttonAutoWidth || false

                        height: props._buttonHeight || defaultButtonHeight

                        anchors.leftMargin: props._leftMargin || defaultLeftMargin || 0

                        anchors.topMargin: props._topMargin || defaultTopMargin || 0

                        textContent: props._textContent || ""
                        margin: props._innerMargin || defaultInnerMargin
                        isToggleButton: managementType === ButtonGroup.ManagementType.Selector
                        pressed: index == selectedIndex
                        showBackground: buttonGroup.showBackground
                        showBorder: false

                        imageWidth: props._imageWidth || defaultImageWidth
                        imageHeight: props._imageHeight || defaultImageHeight
                        imageSource: props._imagePath || ""

                        hoverMessage: props._hoverMessage || ""
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
