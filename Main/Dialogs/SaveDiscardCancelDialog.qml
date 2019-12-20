/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

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
