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

import QtQuick 2.14

ButtonGroup {
    id: windowButtonsContainer

    property bool disableMinimize: false
    property bool disableMaximize: false
    property bool disableClose:    false

    signal minimizePressed()
    signal maximizePressed()
    signal closePressed()

    defaultButtonWidth: 26
    defaultButtonHeight: 20
    defaultImageWidth: 8
    defaultImageHeight: 8

    fixedWidth: false

    buttons: ListModel {
        // https://stackoverflow.com/a/33161093/8166701
        property bool completed: false
        Component.onCompleted: {
            buttons.setProperty(0, "isDisabled", disableMinimize);
            buttons.setProperty(1, "isDisabled", disableMaximize);
            buttons.setProperty(2, "isDisabled", disableClose);
            completed = true;
        }

        ListElement {
            imageSource: "Images/Minimize.svg"
            isDisabled: false
            hoverMessage: qsTr("Minimize")
            onClicked: () => {
               windowButtonsContainer.minimizePressed();
            }
        }
        ListElement {
            imageSource: "Images/Maximize.svg"
            isDisabled: false
            hoverMessage: qsTr("Maximize")
            onClicked: () => {
               windowButtonsContainer.maximizePressed();
            }
        }
        ListElement {
            imageSource: "Images/Close.svg"
            isDisabled: false
            hoverMessage: qsTr("Close")
            onClicked: () => {
               windowButtonsContainer.closePressed();
            }
        }
    }

    onDisableMinimizeChanged: {
        buttons.setProperty(0, "isDisabled", disableMinimize);
    }
    onDisableMaximizeChanged: {
        buttons.setProperty(1, "isDisabled", disableMaximize);
    }
    onDisableCloseChanged: {
        buttons.setProperty(2, "isDisabled", disableClose);
    }
}
