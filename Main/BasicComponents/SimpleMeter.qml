import QtQuick 2.0

Rectangle {
    property real value: 0
    property bool isVertical: false

    color: Qt.rgba(1, 1, 1, 0.09)
    radius: 0.5

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        height: isVertical ? parent.height * value : parent.height
        width: isVertical ? parent.width : parent.width * value

        radius: 0.5
        color: Qt.hsla(162 / 360, 0.5, 0.43, 1);
    }
}
