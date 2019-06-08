import QtQuick 2.13
import QtQuick.Controls 2.13
import "BasicComponents"

SplitView {
    orientation: Qt.Horizontal

    Rectangle {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 500
        color: "transparent"
        SplitView.fillWidth: true
    }

    Rectangle {
        implicitWidth: 145
        SplitView.preferredWidth: 145
        SplitView.maximumWidth: 145
        SplitView.minimumWidth: 145
        color: "transparent"
    }

    Rectangle {
        SplitView.minimumWidth: 50
        color: "transparent"
    }

    handle: Rectangle {
        implicitWidth: 3
        implicitHeight: this.height

        color: Qt.rgba(1, 1, 1, 0.2)
    }
}
