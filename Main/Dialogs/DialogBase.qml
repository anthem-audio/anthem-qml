/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

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
        }

        MoveHandle {
            window: dialog
            anchors.fill: parent
        }
    }
}
