import QtQuick 2.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.2

import "BasicComponents"
import "Global"

Panel {
    height: 44
    Item {
        id: controlPanelSpacer
        anchors.fill: parent
        anchors.margins: 6

        // Float left

        Button {
            id: btnLogo // No idea what this button does. Possibly opens up a dialog with info about the software? Or a welcome dialog or something.
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.height // makes it square :)

            imageSource: "Images/Logo.svg"
            imageWidth: 14
            imageHeight: 12
        }

        Button {
            id: btnFile
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnLogo.right
            anchors.leftMargin: 2
            width: parent.height

            textContent: "File"

            hasMenuIndicator: true

            onPress: fileMenu.open()

            Menu {
                id: fileMenu
                y: parent.height

                MenuItem {
                    text: 'New project'
                }
                MenuItem {
                    FileDialog {
                        id: loadFileDialog
                        title: "Select a project"
                        folder: shortcuts.home
                        nameFilters: ["Anthem project files (*.anthem)"]
                        onAccepted: {
                            Anthem.loadProject(loadFileDialog.fileUrl.toString().substring(8));
                        }
                    }

                    text: 'Open...'
                    onTriggered: {
                        loadFileDialog.open();
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: 'Save'
                }
                MenuItem {
                    text: 'Save as...'
                }
                MenuSeparator {}
                MenuItem {
                    text: 'Exit'
                }
            }
        }



        Button {
            id: btnSave
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnFile.right
            anchors.leftMargin: 20
            width: parent.height

            imageSource: "Images/Save.svg"
            imageWidth: 16
            imageHeight: 16
        }

        Button {
            id: btnUndo
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnSave.right
            anchors.leftMargin: 2
            width: parent.height

            imageSource: "Images/Undo.svg"
            imageWidth: 15
            imageHeight: 15
        }

        Button {
            id: btnRedo
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnUndo.right
            anchors.leftMargin: 2
            width: parent.height

            imageSource: "Images/Redo.svg"
            imageWidth: 15
            imageHeight: 15
        }



        // Float middle
        Item {
            /*
              This item is used to center a group of contorls in its parent.

              In a perfect world, I would have the item adapt to the width of its
                content and then center itself in the parent, but I don't know how
                to do the former and I'm on a plane right now so I'm going to have
                to settle for hard-coding the width.

              -- Joshua Wade, Jun 11, 2019
              */

            id: centerPositioner
            width: 498
            height: parent.height
            anchors.centerIn: parent

            Button {
                id: btnMetronomeToggle
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.height

                isToggleButton: true

                imageSource: "Images/Metronome.svg"
                imageWidth: 13
                imageHeight: 16
            }

            Button {
                id: idk
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: btnMetronomeToggle.right
                anchors.leftMargin: 3
                width: 21
            }

            // Still don't have a button group. Not sure how I'd make one.
            Rectangle {
                id: playbackControlsGroup
                width: 125
                anchors.top: parent.top
                anchors.left: idk.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 3
                radius: 2
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.4)

                Button {
                    id: btnPlay
                    showBorder: false
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: parent.height - 2

                    anchors.topMargin: 1
                    anchors.leftMargin: 1
                    anchors.bottomMargin: 1

                    imageSource: "Images/Play.svg"
                    imageWidth: 12
                    imageHeight: 12
                }

                Button {
                    id: btnRecord
                    showBorder: false
                    anchors.top: parent.top
                    anchors.left: btnPlay.right
                    anchors.bottom: parent.bottom
                    width: parent.height - 2

                    anchors.topMargin: 1
                    anchors.leftMargin: 1
                    anchors.bottomMargin: 1

                    imageSource: "Images/Record.svg"
                    imageWidth: 12
                    imageHeight: 12
                }

                Button {
                    id: btnPlayRecord
                    showBorder: false
                    anchors.top: parent.top
                    anchors.left: btnRecord.right
                    anchors.bottom: parent.bottom
                    width: parent.height - 2

                    anchors.topMargin: 1
                    anchors.leftMargin: 1
                    anchors.bottomMargin: 1

                    imageSource: "Images/Play and Record.svg"
                    imageWidth: 16
                    imageHeight: 16
                }

                Button {
                    id: btnStop
                    showBorder: false
                    anchors.top: parent.top
                    anchors.left: btnPlayRecord.right
                    anchors.bottom: parent.bottom
                    width: parent.height - 2

                    anchors.topMargin: 1
                    anchors.leftMargin: 1
                    anchors.bottomMargin: 1

                    imageSource: "Images/Stop.svg"
                    imageWidth: 12
                    imageHeight: 12
                }

                Rectangle {
                    anchors.left: btnPlay.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    color: Qt.rgba(0, 0, 0, 0.4)
                    width: 1
                }

                Rectangle {
                    anchors.left: btnRecord.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    color: Qt.rgba(0, 0, 0, 0.4)
                    width: 1
                }

                Rectangle {
                    anchors.left: btnPlayRecord.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    color: Qt.rgba(0, 0, 0, 0.4)
                    width: 1
                }
            }

            Button {
                id: btnLoop
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: playbackControlsGroup.right
                anchors.leftMargin: 3
                width: parent.height

                isToggleButton: true

                imageSource: "Images/Loop.svg"
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

                    Text {
                        text: qsTr("128.00")
                        font.family: Fonts.sourceCodeProSemiBold.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.topMargin: 2
                        color: "#1ac18f"
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Item {
                    id: spacer2
                    anchors.top: spacer1.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 7

                    Text {
                        text: qsTr("4/4")
                        font.family: Fonts.sourceCodeProSemiBold.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.bottomMargin: 2
                        color: "#1ac18f"
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
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
                        text: qsTr("1.1.1.00")
                        font.family: Fonts.sourceCodeProSemiBold.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.topMargin: 2
                        color: "#1ac18f"
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
                        text: qsTr("0:00.00")
                        font.family: Fonts.sourceCodeProSemiBold.name
                        font.weight: Font.Bold
                        font.pointSize: 10
                        anchors.fill: parent
                        anchors.bottomMargin: 2
                        color: "#1ac18f"
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
                        font.family: Fonts.notoSansRegular.name
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
                        anchors.top: pitchLabel.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.bottom: parent.bottom

                        highBound: 48
                        lowBound: -48
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
                            source: 'Images/CPU.svg'
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: parent.width
                            visible: false
                        }

                        ColorOverlay {
                            anchors.fill: cpuIcon
                            source: cpuIcon
                            color: Qt.rgba(1, 1, 1, 1)
                            opacity: 0.65
                        }

                        Image {
                            id: outputIcon
                            source: 'Images/Output Level.svg'
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.width
                            visible: false
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
            id: btnIGenuinelyDontKnow
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.height

            imageSource: "Images/Knob.svg"
            imageWidth: 16
            imageHeight: 16
        }
    }
}
