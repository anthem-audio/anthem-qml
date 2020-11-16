/*
    Copyright (C) 2019, 2020 Joshua Wade

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

// Renders a project. Visiblity is toggled by which tab is selected.

import QtQuick 2.15
import "BasicComponents"
import "Global"

Item {
    id: project

    anchors.fill: parent

    property int historyPointer: -1
    property var history: []

    property string key

    // Declaratively show this tab content if the key matches the active tab key
    visible: key === globalStore.selectedTabKey

    // All commands must have exec() and undo(). This is not enforced at runtime.
    function exec(command) {
        // If the history pointer isn't at the end, remove the tail
        if (historyPointer + 1 !== history.length) {
            history.splice(historyPointer + 1);
        }

        history.push(command);
        historyPointer++;
        command.exec(command.execData);
    }

    function undo() {
        const command = history[historyPointer];
        if (!command) return;

        historyPointer--;
        command.undo(command.undoData);

        // This might do bad things for translation
        globalStore.statusMessage = `${qsTr('Undo')} ${command.description}`;
    }

    function redo() {
        const command = history[historyPointer + 1];
        if (!command) return;

        historyPointer++;
        command.exec(command.execData);

        globalStore.statusMessage = `${qsTr('Redo')} ${command.description}`;
    }

    Item {
        id: mainContentContainer

        anchors {
            leftMargin: 3
            rightMargin: 3
            bottomMargin: 10

            top: parent.top
            left: parent.left
            right: parent.right
            bottom: footerContainer.top
        }

        ControlsPanel {
            id: controlsPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }

        MainStack {
            id: mainStack
            anchors.top: controlsPanel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 4
            showControllerRack: btnShowControllerRack.pressed
            showExplorer: explorerTabs.selectedIndex > -1
            showEditors: editorPanelTabs.selectedIndex > -1
        }
    }

    Item {
        id: footerContainer
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: 10
            leftMargin: 5
            rightMargin: 5
        }
        height: 15
        width: 65

        ButtonGroup {
            id: explorerTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            showBackground: false
            defaultButtonWidth: 25
            defaultImageWidth: 15
            defaultButtonHeight: 15
            defaultLeftMargin: 20
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 0
            allowDeselection: true
            fixedWidth: false

            ListModel {
                id: explorerTabsModel

                ListElement {
                    leftMargin: 15
                    imageSource: "Images/icons/bottom-bar/browser-panel.svg"
                    hoverMessage: qsTr("File explorer")
                }

                ListElement {
                    imageSource: "Images/icons/bottom-bar/project-panel.svg"
                    imageWidth: 11
                    buttonWidth: 16
                    leftMargin: 15
                    hoverMessage: qsTr("Project explorer")
                }
            }

            buttons: explorerTabsModel
        }

        Rectangle {
            id: spacer1
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: explorerTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        ButtonGroup {
            id: layoutTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: spacer1.right
            anchors.leftMargin: 5
            showBackground: false
            defaultButtonHeight: 15
            defaultLeftMargin: 15
            buttonAutoWidth: true
            defaultInnerMargin: 0
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 0
            fixedWidth: false

            buttons: layoutTabsModel

            ListModel {
                id: layoutTabsModel
                ListElement {
                    textContent: qsTr("ARRANGE")
                    hoverMessage: qsTr("Arrangement layout")
                }
                ListElement {
                    textContent: qsTr("MIX")
                    hoverMessage: qsTr("Mixing layout")
                }
                ListElement {
                    textContent: qsTr("EDIT")
                    hoverMessage: qsTr("Editor layout")
                }
            }
        }

        Rectangle {
            id: spacer2
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: layoutTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        ButtonGroup {
            id: editorPanelTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: spacer2.right
            showBackground: false
            defaultButtonWidth: 25
            defaultImageWidth: 15
            defaultButtonHeight: 15
            defaultLeftMargin: 10
            defaultTopMargin: 0
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 3
            allowDeselection: true
            fixedWidth: false

            ListModel {
                id: editorPanelTabsModel
                ListElement {
                    imageSource: "Images/icons/bottom-bar/midi-editor1.svg"
                    hoverMessage: qsTr("Piano roll")
                    leftMargin: 20
                }
                ListElement {
                    imageSource: "Images/icons/bottom-bar/automation-editor.svg"
                    hoverMessage: qsTr("Automation editor")
                }
                ListElement {
                    imageSource: "Images/icons/bottom-bar/instrument-effects-panel.svg"
                    hoverMessage: qsTr("Plugin rack")
                }
                ListElement {
                    imageSource: "Images/icons/bottom-bar/mixer.svg"
                    hoverMessage: qsTr("Mixer")
                }
            }

            buttons: editorPanelTabsModel
        }

        Rectangle {
            id: spacer3
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: editorPanelTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        Text {
            id: statusText
            anchors.left: spacer3.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            text: globalStore.statusMessage
            font.family: Fonts.mainRegular.name
            font.pixelSize: 11
            color: Qt.rgba(1, 1, 1, 0.6)
        }

        Button {
            id: btnShowControllerRack
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 15
            width: 15
            imageSource: "Images/icons/bottom-bar/automation-panel.svg"
            imageWidth: 15
            imageHeight: 15
            showBackground: false
            isToggleButton: true
            pressed: true
            hoverMessage: pressed ? qsTr("Hide controller rack") : qsTr("Show controller rack")
        }
    }
}
