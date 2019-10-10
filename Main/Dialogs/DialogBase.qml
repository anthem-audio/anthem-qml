import QtQuick 2.13
import QtQuick.Window 2.13
import "../BasicComponents"
import "../Global"
import ".."

Window {
    id: dialog
    flags: Qt.Window | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    width: 500
    height: 200

    property string title: "Anthem"

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
        height: 30

        Item {
            id: headerControls
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: margin
            anchors.leftMargin: margin
            anchors.rightMargin: margin
            anchors.bottomMargin: margin

            Text {
                text: title
                anchors.left: parent.left
                anchors.top: parent.top
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 11
                color: Qt.hsla(0, 0, 1, 0.7)
                anchors.topMargin: 2
                anchors.leftMargin: 5
            }

            WindowControls {
                id: windowControlButtons
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                disableMinimize: true
                disableMaximize: true

                onClosePressed: {
                    dialog.close()
                }
            }
        }

        MoveHandle {
            window: dialog
            anchors.fill: parent
        }
    }
}
