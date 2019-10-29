import QtQuick 2.13

/*
  Model structure below.
  All properties can be omitted except width and height.
  {
    width:        real,
    height:       real,
    autoWidth:    bool,
    leftMargin:   real,
    rightMargin:  real,
    topMargin:    real,
    bottomMargin: real,
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

    Repeater {
        anchors.fill: parent
        model: buttonGroup.model
        Item {
            width: (modelData.width || defaultWidth) + (modelData.leftMargin || 0) + (modelData.rightMargin || 0)
            height: (modelData.height || defaultHeight) + (modelData.topMargin || 0) + (modelData.bottomMargin || 0)
            Button {
                anchors.fill: parent
                anchors.leftMargin: modelData.leftMargin || 0
                anchors.rightMargin: modelData.rightMargin || 0
                anchors.topMargin: modelData.topMargin || 0
                anchors.bottomMargin: modelData.bottomMargin || 0

                textContent: modelData.textContent || ""
                pressed: modelData.pressed || false
                showBackground: buttonGroup.showBackground

                imageWidth: modelData.imageWidth || 0
                imageHeight: modelData.imageHeight || 0
                imageSource: modelData.imagePath || ""
            }
        }
    }
}
