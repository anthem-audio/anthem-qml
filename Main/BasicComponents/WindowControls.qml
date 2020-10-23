/*
    Copyright (C) 2019 - 2020 Joshua Wade

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

import QtQuick 2.15

Item {
    signal minimizePressed()
    signal maximizePressed()
    signal closePressed()

    Button {
        id: closeButton
        width: 20
        height: 20
        anchors {
            top: parent.top
            right: parent.right
        }

        imageSource: "Images/icons/small/close.svg"
        imageWidth: 8
        imageHeight: 8

        showBorder: false
        showBackground: false

        onClicked: closePressed()
    }

    Button {
        id: maximizeButton
        width: 20
        height: 20
        anchors {
            top: parent.top
            right: closeButton.left
            rightMargin: 4
        }

        imageSource: "Images/icons/small/maximize.svg"
        imageWidth: 8
        imageHeight: 8

        showBorder: false
        showBackground: false

        onClicked: maximizePressed()
    }

    Button {
        id: minimizeButton
        width: 20
        height: 20
        anchors {
            top: parent.top
            right: maximizeButton.left
            rightMargin: 4
        }

        imageSource: "Images/icons/small/minimize.svg"
        imageWidth: 8
        imageHeight: 8

        showBorder: false
        showBackground: false

        onClicked: minimizePressed()
    }
}
