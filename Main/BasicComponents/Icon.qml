import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: icon
    property string imageSource: ''
    property real   imageWidth: width
    property real   imageHeight: height

    property color  color: 'white'

    Image {
        id: image
        // If the source is defined, use it. Otherwise, use a transparent 1-pixel PNG.
        source:
            imageSource != ''
                ? '../' + imageSource
                : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
        width: imageWidth + 2
        height: imageHeight + 2
        anchors.centerIn: parent
        sourceSize.width: imageWidth
        sourceSize.height: imageHeight
        fillMode: Image.PreserveAspectFit
        visible: false
        sourceClipRect: Qt.rect(-1, -1, imageWidth + 2, imageHeight + 2)
    }
    ColorOverlay {
        anchors.fill: image
        source: image
        visible: true
        color: icon.color
    }
}
