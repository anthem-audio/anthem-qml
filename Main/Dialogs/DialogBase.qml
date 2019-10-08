import QtQuick 2.13
import QtQuick.Window 2.13
import "../BasicComponents"
import ".."

Window {
    id: dialog
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    width: 500
    height: 200
    readonly property int margin: 5

    Rectangle {
        anchors.fill: parent
        color: "#454545"
    }

    Item {
        id: headerControlsContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: margin
        anchors.leftMargin: margin
        anchors.rightMargin: margin
        height: 20

        WindowControls {
            id: windowControlButtons
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            onClosePressed: {
                dialog.close()
            }
        }

        MoveHandle {
            window: dialog
            anchors.fill: parent
        }
    }
}
