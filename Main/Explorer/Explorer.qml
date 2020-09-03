/*
    Copyright (C) 2020 Joshua Wade

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

import "../BasicComponents"
import "../Global"

Item {
    id: explorer
    property bool isNotesVisible: notesButton.pressed

    anchors.margins: 6

    // This is awful, but I should at least describe what's going
    // on. ButtonGroup is a mess and I don't feel like fixing it
    // right now, but it has no way to automatically pad buttons
    // to fill space. It does, however, let you set the margins
    // of each button when their width is automatically
    // determined. So, I'm using this awful thing to calculate
    // the width of the text in all the buttons so I can get
    // values for the margins.
    Row {
        id: textWidthCalculator
        visible: false
        onWidthChanged: console.log(width)

        Text {
            text: qsTr("Plugins")
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 11
        }
        Text {
            text: qsTr("Audio")
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 11
        }
        Text {
            text: qsTr("Projects")
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 11
        }
        Text {
            text: qsTr("Files")
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 11
        }
    }

    ButtonGroup {
        id: tabs

        visible: !explorer.isNotesVisible

        fixedWidth: false
        buttonAutoWidth: true

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 20
        defaultButtonHeight: 20
        defaultInnerMargin: (parent.width - textWidthCalculator.width - 18) / 8

        managementType: ButtonGroup.ManagementType.Selector
        selectedIndex: 0

        buttons: explorerTabsModel

        ListModel {
            id: explorerTabsModel
            ListElement {
                textContent: qsTr("Plugins")
            }
            ListElement {
                textContent: qsTr("Audio")
            }
            ListElement {
                textContent: qsTr("Projects")
            }
            ListElement {
                textContent: qsTr("Files")
            }
        }
    }

//    Item {
//        id: contentArea

//        visible: !explorer.isNotesVisible

//        anchors {
//            left: parent.left
//            right: parent.right
//            top: tabs.bottom
//            topMargin: 2
//            bottom: footer.top
//            bottomMargin: 2
//        }
//    }

    Item {
        id: footer

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 20

        Button {
            id: notesButton
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: 20
            imageSource: "Images/Page With Text.svg"
            imageWidth: 10
            imageHeight: 12
            isToggleButton: true
        }
    }
}
