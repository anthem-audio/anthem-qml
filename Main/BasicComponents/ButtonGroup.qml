import QtQuick 2.13

/*
    Model structure below.
    If a property is not given, the default will be used.

    ListModel {
    // ...
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
    }
  */

Flow {
    id: buttonGroup
    property var  model: []
    property bool isSelector: false
    property bool showBackground: true
    property real defaultWidth
    property real defaultHeight
    property real defaultImageWidth: defaultWidth
    property real defaultImageHeight: defaultHeight
    property real defaultLeftMargin
    property real defaultTopMargin
    property bool buttonAutoWidth: false
    property real defaultInnerMargin
    property int  managementType: ButtonGroup.ManagementType.None
    property int  selectedIndex: -1
    property int  _oldSelectedIndex: selectedIndex
    property bool allowDeselection: false

    onSelectedIndexChanged: {
        if (repeater.itemAt(0) === null) {
            return;
        }

        if (_oldSelectedIndex > -1) {
            repeater.itemAt(_oldSelectedIndex).children[0].pressed = false;
        }
        if (selectedIndex > -1) {
            repeater.itemAt(selectedIndex).children[0].pressed = true;
        }

        _oldSelectedIndex = selectedIndex;
    }

    enum ManagementType {
        None,
        Selector
    }

    Repeater {
        id: repeater
        anchors.fill: parent
        model: buttonGroup.model
        Item {
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
            }

            width: {
                let baseWidth;

                if (props._autoWidth || (props._autoWidth === undefined && buttonAutoWidth)) {
                    baseWidth = btn.width;
                }
                else {
                    baseWidth = props._buttonWidth || defaultWidth;
                }

                return baseWidth + (props._leftMargin || defaultLeftMargin || 0)
            }
            height: (props._buttonHeight || defaultHeight)
                    +
                    (props._topMargin || defaultTopMargin || 0)
            Button {
                id: btn
                anchors.left: parent.left
                anchors.top: parent.top
                width: props._autoWidth ? undefined : (props._buttonWidth || defaultWidth)

                textAutoWidth: props._autoWidth || buttonAutoWidth || false

                height: props._buttonHeight || defaultHeight

                anchors.leftMargin: props._leftMargin || defaultLeftMargin || 0

                anchors.topMargin: props._topMargin || defaultTopMargin || 0

                textContent: props._textContent || ""
                margin: props._innerMargin || defaultInnerMargin
                isToggleButton: managementType === ButtonGroup.ManagementType.Selector
                pressed: index == selectedIndex
                showBackground: buttonGroup.showBackground
                showBorder: buttonGroup.showBackground

                imageWidth: props._imageWidth || defaultImageWidth
                imageHeight: props._imageHeight || defaultImageHeight
                imageSource: props._imagePath || ""

                hoverMessage: props._hoverMessage || ""
            }
            MouseArea {
                anchors.fill: btn
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
