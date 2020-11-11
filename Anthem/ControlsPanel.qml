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

import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.15

import "BasicComponents"
import "Global"
import "Menus"

Rectangle {
    id: controlsPanel
    property real spacerMargins: 7

    height: 42

    function updateAll() {
        timeSignatureNumeratorControl.value = Anthem.getTimeSignatureNumerator();
        timeSignatureDenominatorControl.value = Anthem.getTimeSignatureDenominator();
        tempoControl.value = Anthem.getBeatsPerMinute();
    }

    radius: 1
    color: colors.white_12

    Item {
        id: paddingItem
        anchors {
            fill: parent
            margins: controlsPanel.spacerMargins
        }

        Row {
            id: groupContainer
            property real totalGroupWidths:
                group1.width + spacerWidth +
                group2.width + spacerWidth +
                group3.width + spacerWidth +
                group4.width + spacerWidth +
                group5.width + spacerWidth +
                group6.width
            property real spacerWidth: 2
            property real groupCount: 6
            property real spacerCount: groupCount * 2 - 2

            property real spacingBase:
                Math.floor(
                    (Screen.devicePixelRatio *
                        (paddingItem.width - totalGroupWidths)) /
                        ((groupCount - 1) * 2)
                ) / Screen.devicePixelRatio;

            Row {
                id: group1

                spacing: 4
                Button {
                    id: btnFile
                    width: 28
                    height: 28

                    imageSource: "Images/icons/file/hamburger.svg"
                    imageWidth: 16
                    imageHeight: 16

                    clickOnMouseDown: true

                    onClicked: fileMenu.open()

                    Shortcut {
                        sequence: "alt+f"
                        onActivated: fileMenu.open()
                    }

                    Menu {
                        id: fileMenu
                        menuX: 0
                        menuY: parent.height

                        menuItems: [
                            {
                                text: qsTr('N_ew project'),
                                shortcut: 'Ctrl+N',
                                hoverText: qsTr('Start a new project'),
                                onTriggered: () => {
                                    Anthem.newProject();
                                }
                            },
                            {
                                text: qsTr('O_pen...'),
                                shortcut: 'Ctrl+O',
                                hoverText: qsTr('Open an existing project'),
                                onTriggered: () => {
                                    saveLoadHandler.openLoadDialog();
                                }
                            },
                            {
                                separator: true
                            },
                            {
                                text: qsTr('S_ave'),
                                shortcut: 'Ctrl+S',
                                hoverText: qsTr('Save this project'),
                                onTriggered: () => {
                                    saveLoadHandler.save();
                                }
                            },
                            {
                                text: qsTr('Save a_s...'),
                                hoverText: qsTr('Save this project to a different file'),
                                onTriggered: () => {
                                    saveLoadHandler.openSaveDialog();
                                }
                            },
                            {
                                separator: true
                            },
                            {
                                text: tempoControl.value.toString()
                            },
                            {
                                text: qsTr('Ex_it'),
                                hoverText: qsTr('Quit Anthem'),
                                onTriggered: () => {
                                    saveLoadHandler.closeWithSavePrompt();
                                }
                            },
                        ]
                    }
                }

                Button {
                    id: btnSave
                    width: 28
                    height: 28
                    hoverMessage: qsTr("Save this project")

                    imageSource: "Images/icons/file/save.svg"
                    imageWidth: 16
                    imageHeight: 16

                    onClicked: saveLoadHandler.save()
                }

                Button {
                    id: btnUndo
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Undo")

                    imageSource: "Images/icons/file/undo.svg"
                    imageWidth: 16
                    imageHeight: 16

                    onClicked: {
                        undo();
                    }
                }

                Button {
                    id: btnRedo
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Redo")

                    imageSource: "Images/icons/file/redo.svg"
                    imageWidth: 16
                    imageHeight: 16

                    onClicked: {
                        redo();
                    }
                }
            }

            ControlsPanelSpacer {
                spacerNumber: 1
            }

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
            }

            ControlsPanelSpacer {
                spacerNumber: 2
            }


            Row {
                id: group2
                spacing: 4

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Toggle metronome")

                    isToggleButton: true

                    imageSource: "Images/icons/control/metronome.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Scroll to playhead")

                    isToggleButton: true

                    imageSource: "Images/icons/control/scroll-follow.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Return playhead to initial position on stop")

                    isToggleButton: true

                    imageSource: "Images/icons/control/afterstop.svg"
                    imageWidth: 16
                    imageHeight: 16
                }
            }

            ControlsPanelSpacer {
                spacerNumber: 3
            }

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
            }

            ControlsPanelSpacer {
                spacerNumber: 4
            }

            Row {
                id: group3
                spacing: 4

                Button {
                    width: 39
                    height: 28

                    hoverMessage: qsTr("I do not know what this does :)")

                    isToggleButton: true

                    imageSource: "Images/icons/media/play-arranger.svg"
                    imageWidth: 27
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Play")

                    isToggleButton: true

                    imageSource: "Images/icons/media/play.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Stop")

                    imageSource: "Images/icons/media/stop.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Record")

                    isToggleButton: true

                    imageSource: "Images/icons/media/record.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Play and start recording")

                    imageSource: "Images/icons/media/play-record.svg"
                    imageWidth: 16
                    imageHeight: 16
                }
            }

            ControlsPanelSpacer {
                spacerNumber: 5
            }

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
            }

            ControlsPanelSpacer {
                spacerNumber: 6
            }

            Row {
                id: group4
                spacing: 2

                Item {
                    height: 28
                    width: 70

                    DigitControl {
                        id: tempoControl

                        anchors {
                            fill: parent
                            rightMargin: 6
                        }

                        lowBound: 10
                        highBound: 999
                        step: 0.01
                        smallestIncrement: 0.01
                        decimalPlaces: 2
                        value: 140
                        property real lastSentValue: 140
                        hoverMessage: qsTr("Tempo")
                        units: qsTr("BPM")

                        fontPixelSize: 16
                        alignment: Text.AlignRight

    //                    onValueChanged: {
    //                        Anthem.setBeatsPerMinute(value, false);
    //                    }

                        onValueChangeCompleted: {
                            const old = lastSentValue;

                            const command = {
                                exec: () => {
                                    lastSentValue = value;
                                    tempoControl.value = value;
                                    Anthem.setBeatsPerMinute(value, true);
                                },
                                undo: () => {
                                    lastSentValue = old;
                                    tempoControl.value = old;
                                    Anthem.setBeatsPerMinute(old, true);
                                },
                                description: qsTr('set BPM')
                            }

                            exec(command);
                        }

                        // This MouseArea changes the step on tempoControl
                        // depending on which digit is clicked.
                        MouseArea {
                            anchors.fill: parent
                            onPressed: {
                                mouse.accepted = false;
                                let distanceFromRight = parent.width - mouseX;
                                if (distanceFromRight <= 10) {
                                    tempoControl.step = 0.01;
                                }
                                else if (distanceFromRight <= 20) {
                                    tempoControl.step = 0.1;
                                }
                                else {
                                    tempoControl.step = 1;
                                }
                            }
                            onReleased: {
                                mouse.accepted = false;
                            }
                            onPositionChanged: {
                                mouse.accepted = false;
                            }
                            cursorShape: Qt.SizeVerCursor
                        }
                    }
                }

                Item {
                    width: 60
                    height: 28

                    DigitControl {
                        id: timeSignatureNumeratorControl
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: timeSignatureSlash.left
                        width: 18
                        hoverMessage: qsTr("Time signature")

                        fontPixelSize: 16
                        alignment: Text.AlignRight

                        lowBound: 1
                        highBound: 16
                        value: 4
                        speedMultiplier: 0.5

//                        onValueChanged: {
//                            Anthem.setTimeSignatureNumerator(value);
//                        }

                        onValueChangeCompleted: {
                            const old = Anthem.getTimeSignatureNumerator();

                            const command = {
                                exec: () => {
                                    timeSignatureNumeratorControl.value = value;
                                    Anthem.setTimeSignatureNumerator(value)
                                },
                                undo: () => {
                                    timeSignatureNumeratorControl.value = old;
                                    Anthem.setTimeSignatureNumerator(old);
                                },
                                description: qsTr('set time signature numerator')
                            }

                            exec(command);
                        }
                    }

                    Text {
                        id: timeSignatureSlash
                        text: "/"
                        font.family: Fonts.monoMedium.name
                        font.pixelSize: 16
                        anchors.centerIn: parent
                        color: colors.white_70
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    DigitControl {
                        id: timeSignatureDenominatorControl
                        anchors.left: timeSignatureSlash.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 18
                        hoverMessage: qsTr("Time signature")

                        fontPixelSize: 16
                        alignment: Text.AlignLeft

                        value: 4
                        acceptedValues: [1, 2, 4, 8, 16]
                        speedMultiplier: 0.5

//                        onValueChanged: {
//                            Anthem.setTimeSignatureDenominator(value);
//                        }

                        onValueChangeCompleted: {
                            const old = Anthem.getTimeSignatureDenominator();

                            const command = {
                                exec: () => {
                                    timeSignatureDenominatorControl.value = value;
                                    Anthem.setTimeSignatureDenominator(value);
                                },
                                undo: () => {
                                    value = old;
                                    timeSignatureDenominatorControl.value = old;
                                    Anthem.setTimeSignatureDenominator(old);
                                },
                                description: qsTr('set time signature denominator')
                            }

                            exec(command);
                        }
                    }
                }

                Text {
                    text: "111.1.1.00"

                    width: 108
                    height: 28

                    font.family: Fonts.monoMedium.name
                    font.pixelSize: 16

                    color: colors.white_70
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    text: "000:00.000"

                    width: 108
                    height: 28

                    font.family: Fonts.monoMedium.name
                    font.pixelSize: 16

                    color: colors.white_70
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            ControlsPanelSpacer {
                spacerNumber: 7
            }

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
            }

            ControlsPanelSpacer {
                spacerNumber: 8
            }

            Row {
                id: group5
                spacing: 4

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Punch in")

                    isToggleButton: true

                    imageSource: "Images/icons/control/punch-in.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Toggle loop points")

                    isToggleButton: true

                    imageSource: "Images/icons/control/repeat.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    width: 28
                    height: 28

                    hoverMessage: qsTr("Punch out")

                    isToggleButton: true

                    imageSource: "Images/icons/control/punch-out.svg"
                    imageWidth: 16
                    imageHeight: 16
                }
            }

            ControlsPanelSpacer {
                spacerNumber: 9
            }

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
            }

            ControlsPanelSpacer {
                spacerNumber: 10
            }

            Row {
                id: group6
                spacing: 4

                Item {
                    height: 28
                    width: 57

                    Icon {
                        imageSource: "Images/icons/not-clickable/cpu.svg"
                        width: 16
                        height: 16
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 4
                        }

                        color: '#fff'
                        opacity: 0.4
                    }

                    SimpleMeter {
                        width: 26
                        height: 16

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 4
                        }

                        value: 0.15
                    }
                }

                Item {
                    height: 28
                    width: 57

                    Icon {
                        imageSource: "Images/icons/not-clickable/in-out.svg"
                        width: 16
                        height: 16
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 4
                        }

                        color: '#fff'
                        opacity: 0.4
                    }

                    Item {
                        width: 26
                        height: 16

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 4
                        }

                        SimpleMeter {
                            anchors {
                                right: parent.right
                                left: parent.left
                                top: parent.top
                            }

                            height: 7

                            value: 0.15
                        }

                        SimpleMeter {
                            anchors {
                                right: parent.right
                                left: parent.left
                                bottom: parent.bottom
                            }

                            height: 7

                            value: 0.05
                        }
                    }
                }

                Button {
                    id: btnMidiLearn // ?
                    width: 28
                    height: 28
                    hoverMessage: qsTr("Midi learn")

                    imageSource: "Images/icons/topbar/learn.svg"
                    imageWidth: 16
                    imageHeight: 16
                }
            }
        }
    }
}
