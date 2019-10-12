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
    readonly property int dialogMargin: 5
    readonly property int dialogTitleBarHeight: 30

    Rectangle {
        anchors.fill: parent
        color: "#454545"
    }

    Item {
        id: headerControlsContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: dialogTitleBarHeight

        Item {
            id: headerControls
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: dialogMargin
            anchors.leftMargin: dialogMargin
            anchors.rightMargin: dialogMargin
            anchors.bottomMargin: dialogMargin

            Text {
                text: title
                anchors.left: parent.left
                font.family: Fonts.notoSansRegular.name
                font.pixelSize: 11
                color: Qt.hsla(0, 0, 1, 0.7)
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: dialogMargin
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
