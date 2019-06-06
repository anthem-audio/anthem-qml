import QtQuick 2.0

Item {
    property bool isTopLeftRounded: true
    property bool isTopRightRounded: true
    property bool isBottomLeftRounded: true
    property bool isBottomRightRounded: true

    property bool showBorder: true

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

        color: Qt.rgba(1, 1, 1, 0.12)
    }

    MouseArea {
        anchors.fill: parent
    }
}
