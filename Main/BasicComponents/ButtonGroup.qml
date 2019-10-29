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
    property var model: []
    property bool isSelector: false
    property bool showBackground: true
    property real defaultWidth
    property real defaultHeight
    property real defaultLeftMargin
    property real defaultTopMargin
    property bool buttonAutoWidth: false
    property real defaultInnerMargin

    Repeater {
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
                pressed: modelData.pressed || false
                showBackground: buttonGroup.showBackground
                showBorder: buttonGroup.showBackground

                imageWidth: modelData.imageWidth || defaultWidth
                imageHeight: modelData.imageHeight || defaultHeight
                imageSource: modelData.imagePath || ""
            }
        }
    }
}
