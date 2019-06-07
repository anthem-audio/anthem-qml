import QtQuick 2.12

Item {
    id: button

    property bool showBorder: true

    QtObject {
        id: buttonProps
        property bool isHoverActive: false
        property bool isClickActive: false
    }

    signal press()

    Rectangle {
        id: border

        visible: showBorder

        anchors.fill: parent

        color: "transparent"

        radius: 2

        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.4)
    }

    GradientBorder {
        id: highlight

        anchors.fill: parent

        anchors.margins: showBorder ? 1 : 0

        borderWidth: 1
    }

    Rectangle {
        id: inside

        anchors.fill: parent
        anchors.margins: showBorder ? 2 : 1

        QtObject {
            id: insideProps
            property real opacity: buttonProps.isClickActive ? 0.09 :
                (buttonProps.isHoverActive ? 0.17 : 0.12)
//            property real colorVal: buttonProps.isClickActive ? 0 : 1
            property real colorVal: 1
        }

        color: Qt.rgba(insideProps.colorVal, insideProps.colorVal, insideProps.colorVal, insideProps.opacity)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.press()

        property alias clickActive: buttonProps.isClickActive

        onPressed: clickActive = true
        onReleased: clickActive = false

        property alias hoverActive: buttonProps.isHoverActive

        hoverEnabled: true
        onEntered: hoverActive = true
        onExited: hoverActive = false
    }
}
