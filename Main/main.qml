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

import QtQuick 2.14
import QtQuick.Window 2.14
import QtQuick.Shapes 1.14
import QtGraphicalEffects 1.14
import QtQuick.Dialogs 1.2
import "BasicComponents"
import "BasicComponents/GenericTooltip"
import "Dialogs"
import "Menus"
import "Global"
import "Commands"

Window {
    id: mainWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    width: 1300
    height: 768
    property bool isMaximized: false
    property bool isClosing: false
    property int tabsRemaining: -1
    readonly property int margin: 5

    Connections {
        target: Anthem
        function onFlush() {
            flush();
        }
    }

    /*
        This stores data used all over the UI. It can be accessed from almost
        anywhere by calling globalStore.(something) Because Qml (tm) (:
    */
    GlobalStore {
        id: globalStore
    }

    Commands {
        id: commands
    }

    // Colors tagged color_(number) are that color at (number)% opacity
    QtObject {
        id: colors
        property string main: '#07d2d4'
        property string main_11: '#1c07d2d4'
        property string background: '#3e4246'

        property string white_100: '#ffffff'
        property string white_70: '#b3ffffff'
        property string white_60: '#99ffffff'
        property string white_40: '#66ffffff'
        property string white_12: '#1fffffff'
        property string white_11: '#1cffffff'
        property string white_10: '#1affffff'
        property string white_7: '#12ffffff'
        property string white_5: '#0dffffff'
        property string white_4: '#0affffff'
        property string white_3: '#08ffffff'

        property string black_45: '#73000000'
        property string black_30: '#4d000000'
        property string black_22: '#38000000'
        property string black_20: '#33000000'
        property string black_15: '#26000000'

        property string meter_yellow: '#f3d444'
        property string meter_red: '#ff4b77'
        property string keys_active: '#009496'
        property string knob: colors.white_12
        property string separator: colors.white_11
        property string scrollbar: '#59ffffff'
    }

    // All commands must have exec() and undo(). This is not enforced at runtime.
    function exec(command) {
        const tabIndex = globalStore.selectedTabIndex;

        // If the history pointer isn't at the end, remove the tail
        if (commands.historyPointers[tabIndex] + 1 !== commands.histories[tabIndex].length) {
            commands.histories[tabIndex].splice(commands.historyPointers[tabIndex] + 1);
        }

        commands.histories[tabIndex].push(command);
        commands.historyPointers[tabIndex]++;
        command.exec(command.execData);
    }

    function undo() {
        const tabIndex = globalStore.selectedTabIndex;

        const command = commands.histories[tabIndex][commands.historyPointers[tabIndex]];
        if (!command) return;

        commands.historyPointers[tabIndex]--;
        command.undo(command.undoData);

        // This might do bad things for translation
        globalStore.statusMessage = `${qsTr('Undo')} ${command.description}`;
    }

    function redo() {
        const tabIndex = globalStore.selectedTabIndex;

        const command = commands.histories[tabIndex][commands.historyPointers[tabIndex] + 1];
        if (!command) return;
        commands.historyPointers[tabIndex]++;
        command.exec(command.execData);

        globalStore.statusMessage = `${qsTr('Redo')} ${command.description}`;
    }

    signal flush();

    onFlush: {
        console.log('f l u s h')
    }

    color: colors.background

    SaveLoadHandler {
        id: saveLoadHandler
    }

    InformationDialog {
        id: infoDialog
    }

    ResizeHandles {
        anchors.fill: parent
        window: mainWindow
    }

    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: undo()
    }

    Shortcut {
        sequence: "Ctrl+Shift+Z"
        onActivated: redo()
    }

    Shortcut {
        sequence: "Ctrl+N"
        onActivated: Anthem.newProject()
    }

    // Ctrl+W lives in TabGroup

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: loadFileDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+S"
        onActivated: saveLoadHandler.save()
    }

    Connections {
        target: mainWindow
        function onClosing() {
            close.accepted = false;
            saveLoadHandler.closeWithSavePrompt()
        }
    }

//    Image {
//        id: asdf
//        source: "file:///C:\\Users\\qbgee\\Pictures\\6p6qwzkpyh921.jpg"
//        anchors.fill: parent
//    }
//    FastBlur {
//        id: blurredbg
//        visible: true
//        anchors.fill: asdf
//        source: asdf
//        radius: 128
//    }

    Item {
        id: header
        width: parent.width
        height: 30

        anchors.top: parent.top

        Item {
            id: headerControlsContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: margin
            anchors.leftMargin: margin
            anchors.rightMargin: margin
            height: 20

            MoveHandle {
                window: mainWindow
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: windowControlButtons.left
                }
            }

            TabGroup {
                id: tabGroup
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                // Width is managed internally by TabGroup

                onLastTabClosed: Qt.quit()
            }

            WindowControls {
                id: windowControlButtons
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                onMinimizePressed: {
                    mainWindow.showMinimized();
                }

                onMaximizePressed: {
                    if (mainWindow.isMaximized)
                        mainWindow.showNormal();
                    else
                        mainWindow.showMaximized();

                    mainWindow.isMaximized = !mainWindow.isMaximized;
                }

                onClosePressed: {
                    saveLoadHandler.closeWithSavePrompt();
                }
            }
        }
    }

    Item {
        id: mainContentContainer

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerContainer.top

        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.bottomMargin: 10

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
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.leftMargin: 5
        anchors.rightMargin: 5
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
            font.family: Fonts.main.name
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
            showBorder: false
            showBackground: false
            isToggleButton: true
            pressed: true
            hoverMessage: pressed ? qsTr("Hide controller rack") : qsTr("Show controller rack")
        }
    }

    TooltipManager {
        anchors.fill: parent
        id: tooltipManager
    }

    Menus {
        id: menuHelper
        anchors.fill: parent
    }
}
