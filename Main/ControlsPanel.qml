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
import QtGraphicalEffects 1.14
import QtQuick.Dialogs 1.2

import "BasicComponents"
import "Global"
import "Menus"

Rectangle {
    height: 42

    function updateAll() {
        timeSignatureNumeratorControl.value = Anthem.getTimeSignatureNumerator();
        timeSignatureDenominatorControl.value = Anthem.getTimeSignatureDenominator();
        tempoControl.value = Anthem.getBeatsPerMinute();
        masterPitchControl.value = Anthem.getMasterPitch();
    }

    Connections {
        target: mainWindow
        function onFlush() {
            updateAll();
        }
    }

    radius: 1
    color: colors.white_12

    Item {
        id: controlPanelSpacer
        anchors {
            fill: parent
            margins: 7
        }

        Row {
            id: groupContainer
            property int totalGroupWidths: group1.width + spacerWidth + group2.width
            property int spacerWidth: 2
            property int groupCount: 6

            spacing: (controlPanelSpacer.width - totalGroupWidths) / groupCount

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

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
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

            Rectangle {
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                width: groupContainer.spacerWidth
                color: colors.white_12
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
        }

        // Float middle
        Item {
            visible: false
            id: centerPositioner
            width: 498
            height: parent.height
            anchors.centerIn: parent

            Button {
                id: btnLoop
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playbackControlsGroup.right
                anchors.leftMargin: 3
                width: parent.height
                hoverMessage: qsTr("Toggle loop points")

                isToggleButton: true

                imageSource: "Images/icons/control/repeat.svg"
                imageWidth: 16
                imageHeight: 14
            }

            Rectangle {
                id: tempoAndTimeSignatureBlock
                anchors.left: btnLoop.right
                anchors.leftMargin: 20
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 61
                radius: 2

                color: Qt.rgba(0, 0, 0, 0.15)
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.4)

                Item {
                    id: spacer1
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.5;
                    anchors.rightMargin: 7

                    DigitControl {
                        id: tempoControl
                        anchors.fill: parent
                        anchors.topMargin: 2

                        lowBound: 10
                        highBound: 999
                        step: 0.01
                        smallestIncrement: 0.01
                        decimalPlaces: 2
                        value: 140
                        property int lastSentValue: 140
                        hoverMessage: qsTr("Tempo")
                        units: qsTr("BPM")

                        fontPixelSize: 13

                        onValueChanged: {
//                            Anthem.setBeatsPerMinute(value, false);
                        }

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
                                if (distanceFromRight <= 8) {
                                    tempoControl.step = 0.01;
                                }
                                else if (distanceFromRight <= 16) {
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
                        }
                    }
                }

                Item {
                    id: spacer2
                    anchors.top: spacer1.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 7

                    DigitControl {
                        id: timeSignatureNumeratorControl
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: timeSignatureSlash.left
                        width: 16
                        hoverMessage: qsTr("Time signature numerator")

                        fontPixelSize: 13

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
                        font.family: Fonts.mono.name
                        font.weight: Font.Bold
                        font.pixelSize: 13
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: timeSignatureDenominatorControl.left
                        color: colors.main
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    DigitControl {
                        id: timeSignatureDenominatorControl
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: value === 16 ? 16 : 8
                        hoverMessage: qsTr("Time signature denominator")

                        fontPixelSize: 13
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
            }

            Rectangle {
                id: playheadInfoBlock
                anchors.left: tempoAndTimeSignatureBlock.right
                anchors.leftMargin: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 95
                radius: 2

                color: Qt.rgba(0, 0, 0, 0.15)
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.4)

                Item {
                    id: spacer3
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.5;
                    anchors.rightMargin: 7

                    Text {
                        text: "1.1.1.00"
                        font.family: Fonts.mono.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.topMargin: 2
                        color: colors.main
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item {
                    id: spacer4
                    anchors.top: spacer3.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 7

                    Text {
                        text: "0:00.00"
                        font.family: Fonts.mono.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.bottomMargin: 2
                        color: colors.main
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle {
                id: pitchBlock
                anchors.left: playheadInfoBlock.right
                anchors.leftMargin: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 39
                radius: 2

                color: Qt.rgba(0, 0, 0, 0.15)
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.4)

                Item {
                    anchors.fill: parent
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1

                    Text {
                        id: pitchLabel
                        text: qsTr("PITCH")
                        font.family: Fonts.main.name
                        font.pointSize: 8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: parent.height * 0.5
                        color: Qt.rgba(1, 1, 1, 0.65)
                    }

                    DigitControl {
                        id: masterPitchControl
                        anchors.top: pitchLabel.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.bottom: parent.bottom
                        hoverMessage: qsTr("Master pitch")
                        units: qsTr("semitones")

                        property int lastSentValue: 0

                        fontFamily: Fonts.main.name

                        highBound: 12
                        lowBound: -12

                        onValueChanged: {
                            Anthem.setMasterPitch(value, false);
                        }

                        onValueChangeCompleted: {
                            const old = lastSentValue;

                            const command = {
                                exec: () => {
                                    masterPitchControl.value = value;
                                    Anthem.setMasterPitch(value, true);
                                    lastSentValue = value;
                                },
                                undo: () => {
                                    masterPitchControl.value = old;
                                    Anthem.setMasterPitch(old, true);
                                    lastSentValue = old;
                                },
                                description: qsTr('set master pitch')
                            }

                            exec(command);
                        }
                    }
                }
            }

            Rectangle {
                id: cpuAndOutputBlock
                anchors.left: pitchBlock.right
                anchors.leftMargin: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 58
                radius: 2

                color: Qt.rgba(0, 0, 0, 0.15)
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.4)

                Item {
                    anchors.fill: parent
                    anchors.margins: 5

                    Item {
                        id: icons
                        width: 9
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left

                        Image {
                            id: cpuIcon
                            source: 'Images/icons/not-clickable/cpu.svg'
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: parent.width
                            visible: false
                            sourceSize.width: width
                            sourceSize.height: height
                        }

                        ColorOverlay {
                            anchors.fill: cpuIcon
                            source: cpuIcon
                            color: Qt.rgba(1, 1, 1, 1)
                            opacity: 0.65
                        }

                        Image {
                            id: outputIcon
                            source: 'Images/icons/not-clickable/in-out.svg'
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.width
                            visible: false
                            sourceSize.width: width
                            sourceSize.height: height
                        }

                        ColorOverlay {
                            anchors.fill: outputIcon
                            source: outputIcon
                            color: Qt.rgba(1, 1, 1, 1)
                            opacity: 0.65
                        }
                    }

                    Item {
                        anchors.left: icons.right
                        anchors.leftMargin: 3
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right

                        SimpleMeter {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 9

                            value: 0.45
                        }

                        Item {
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            height: 9

                            SimpleMeter {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 4

                                value: 0.7
                            }

                            SimpleMeter {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 4
                                value: 0.8
                            }
                        }
                    }
                }
            }
        }

        // Float right

        Button {
            id: btnMidiLearn // ?
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.height
            hoverMessage: qsTr("Midi learn")

            imageSource: "Images/icons/topbar/learn.svg"
            imageWidth: 16
            imageHeight: 16
        }
    }
}
