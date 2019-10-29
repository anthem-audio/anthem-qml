import QtQuick 2.13

/*
  Model structure below.
  All properties can be omitted except width and height.
  {
    width:        real,
    height:       real,
    autoWidth:    bool,
    leftMargin:   real,
    topMargin:    real,
    textContent:  string,
    imagePath:    string,
    pressed:      bool,
  }
  */

Flow {
    id: buttonGroup
    property var  model: []
    property bool isSelector: false
    property bool showBackground: true
    property real defaultWidth
    property real defaultHeight
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
            width: {
                let baseWidth;

                if (modelData.autoWidth || (modelData.autoWidth === undefined && buttonAutoWidth)) {
                    baseWidth = btn.width;
                }
                else {
                    baseWidth = modelData.width || defaultWidth;
                }

                return baseWidth + (modelData.leftMargin || defaultLeftMargin || 0)
            }
            height: (modelData.height || defaultHeight) + (modelData.topMargin || defaultTopMargin || 0)
            Button {
                id: btn
                anchors.left: parent.left
                anchors.top: parent.top
                width: modelData.autoWidth ? undefined : (modelData.width || defaultWidth)
                textAutoWidth: modelData.autoWidth || buttonAutoWidth || false

                height: modelData.height || defaultHeight
                anchors.leftMargin: modelData.leftMargin || defaultLeftMargin || 0
                anchors.topMargin: modelData.topMargin || defaultTopMargin || 0

                textContent: modelData.textContent || ""
                margin: modelData.innerMargin || defaultInnerMargin
                isToggleButton: managementType === ButtonGroup.ManagementType.Selector
                pressed: index == selectedIndex
                showBackground: buttonGroup.showBackground
                showBorder: buttonGroup.showBackground

                imageWidth: modelData.imageWidth || defaultWidth
                imageHeight: modelData.imageHeight || defaultHeight
                imageSource: modelData.imagePath || ""
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
