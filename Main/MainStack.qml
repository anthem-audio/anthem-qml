import QtQuick 2.13
import QtQuick.Controls 2.13
import "BasicComponents"

SplitView {
    id: mainStack
    orientation: Qt.Horizontal
    property bool showControllerRack
    property bool showExplorer
    property bool showEditors

    Panel {
        visible: showExplorer
        implicitWidth: 200
        SplitView.minimumWidth: 200
    }

    CenterStack {
        SplitView.fillWidth: true
        showEditors: mainStack.showEditors
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
