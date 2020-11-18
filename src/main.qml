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

import Anthem 1.0

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

    /*
        This stores data used all over the UI. It can be accessed from almost
        anywhere by calling globalStore.(something) Because Qml (tm) (:
    */
    GlobalStore {
        id: globalStore
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

    Image {
        id: asdf
        source: "file:///C:\\Users\\qbgee\\Pictures\\background.jpg"
        width: Screen.width
        height: Screen.height
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    FastBlur {
        id: blurredbg
        visible: true
        anchors.fill: asdf
        source: asdf
        radius: 128
        opacity: 0.3
    }
    Rectangle {
        anchors.fill: parent
        color: colors.black_30
    }

    Item {
        id: header
        width: parent.width
        height: 40

        anchors.top: parent.top

        Item {
            id: headerControlsContainer
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 3
                leftMargin: 3
                rightMargin: 3
            }

            // Rectangle to the right of the tab group that
            // contains the window controls
            AsymRoundRect {
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    left: tabGroup.right
                    bottomMargin: 1
                }
                startRadius: 2
                endRadius: 1
                direction: AsymRoundRect.Direction.Vertical
                color: colors.white_7
            }

            MoveHandle {
                window: mainWindow
                anchors.fill: parent
            }

            AsymRoundRect {
                id: anthemButtonContainer
                startRadius: 2
                endRadius: 1
                direction: AsymRoundRect.Direction.Vertical
                color: colors.white_7

                anchors {
                    left: parent.left
                    top: parent.top
                }

                width: 36
                height: 36

                Button {
                    id: btnLogo
                    anchors.fill: parent

                    showBackground: false
                    isToggleButton: true

                    imageSource: "Images/icons/main/anthem.svg"
                    imageWidth: 16
                    imageHeight: 16

                    hoverMessage: btnLogo.pressed ? qsTr("Stop engine for this tab") : qsTr("Start engine for this tab")
                }
            }

            TabGroup {
                id: tabGroup
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: anthemButtonContainer.right
                    leftMargin: 1
                }

                // Width is managed by TabGroup
            }

            WindowControls {
                id: windowControlButtons
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 8
                    rightMargin: 8
                    bottomMargin: 8
                }

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

    ProjectSwitcher {
        id: projectSwitcher
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
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
