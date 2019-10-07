import QtQuick 2.13

// We need a ButtonGroup here, but as of writing this comment, I haven't created one yet.
//   -- Joshua Wade, Jun 4, 2019

Rectangle {
    id: windowButtonsContainer

    width: 28 + 26 + 28
    color: "transparent"
    border.color: Qt.rgba(0, 0, 0, 0.4)
    radius: 2

    signal minimizePressed()
    signal maximizePressed()
    signal closePressed()

    Button {
        id: btnMinimize
        width: 26
        anchors.right: spacer1.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        anchors.leftMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1

        showBorder: false

        imageSource: "Images/Minimize.svg"
        imageWidth: 8
        imageHeight: 8

        onPress: {
            windowButtonsContainer.minimizePressed();
        }
    }
    Rectangle {
        id: spacer1
        width: 1
        anchors.right: btnMaximize.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    Button {
        id: btnMaximize
        width: 26
        anchors.right: spacer2.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        anchors.topMargin: 1
        anchors.bottomMargin: 1

        showBorder: false

        imageSource: "Images/Maximize.svg"
        imageWidth: 8
        imageHeight: 8

        onPress: {
            windowButtonsContainer.maximizePressed();
        }
    }
    Rectangle {
        id: spacer2
        width: 1
        anchors.right: btnClose.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        color: Qt.rgba(0, 0, 0, 0.4)
    }
    Button {
        id: btnClose
        width: 26
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        anchors.rightMargin: 1
        anchors.topMargin: 1
        anchors.bottomMargin: 1

        showBorder: false

        imageSource: "Images/Close.svg"
        imageWidth: 8
        imageHeight: 8

        onPress: {
            windowButtonsContainer.closePressed();
        }
    }
}
