import QtQuick 2.13
import "../BasicComponents"
import "../Global"

DialogBase {
    id: dialog
    readonly property int dialogButtonContainerHeight: 40
    property string message: ""
    property string saveButtonText: "Save"
    property string discardButtonText: "Discard"
    property string cancelButtonText: "Cancel"

    readonly property real buttonWidth: Math.max(btnSave.textWidth, btnDiscard.textWidth, btnCancel.textWidth) + margin * 2 + 3

    signal savePressed()
    signal discardPressed()
    signal cancelPressed()

    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.bottom: buttonContainer.top
        anchors.topMargin: dialogTitleBarHeight

        Text {
            text: message
            wrapMode: Text.Wrap
            color: Qt.rgba(1, 1, 1, 0.7)
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 16
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: margin * 3
            anchors.leftMargin: margin * 3
            anchors.rightMargin: margin * 3
        }
    }

    Item {
        id: buttonContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: dialogButtonContainerHeight

        Button {
            id: btnSave
            height: 20
            width: buttonWidth
            anchors.right: btnDiscard.left
            anchors.rightMargin: dialogMargin
            anchors.verticalCenter: parent.verticalCenter
            textContent: saveButtonText
            onPress: {
                dialog.close()
                savePressed()
            }
        }

        Button {
            id: btnDiscard
            height: 20
            width: buttonWidth
            anchors.right: btnCancel.left
            anchors.rightMargin: dialogMargin
            anchors.verticalCenter: parent.verticalCenter
            textContent: discardButtonText
            onPress: {
                dialog.close()
                discardPressed()
            }
        }

        Button {
            id: btnCancel
            height: 20
            width: buttonWidth
            anchors.right: parent.right
            anchors.rightMargin: dialogMargin * 2
            anchors.verticalCenter: parent.verticalCenter
            textContent: cancelButtonText
            onPress: {
                dialog.close()
                cancelPressed()
            }
        }
    }
}
