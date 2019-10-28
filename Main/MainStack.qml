import QtQuick 2.13
import QtQuick.Controls 2.13
import "BasicComponents"

SplitView {
    orientation: Qt.Horizontal
    property bool showControllerRack
    Panel {
        implicitWidth: 200
        SplitView.minimumWidth: 200
    }

    CenterStack {
        SplitView.fillWidth: true
    }

    Panel {
        visible: showControllerRack
        implicitWidth: 200
        SplitView.minimumWidth: 200
    }

    handle: Rectangle {
        implicitWidth: 4
        implicitHeight: this.height

        color: "transparent"
    }
}
