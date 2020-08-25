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

import "../../BasicComponents"

Item {
    readonly property int contentMargins: 3

    Rectangle {
        id: channelBackground
        color: Qt.rgba(1, 1, 1, 0.05)
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            left: colorPickerButton.right
            leftMargin: -1
        }

        Item {
            anchors {
                fill: parent
                topMargin: 3
                bottomMargin: 3
            }

            Rectangle {
                id: channelPickerContainer

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    leftMargin: contentMargins + 1 // *shrug*
                }

                width: 27

                border.color: Qt.rgba(0, 0, 0, 0.4)
                border.width: 1
                radius: 1
                color: Qt.rgba(0, 0, 0, 0.15)

                DigitControl {
                    anchors.fill: parent
                    anchors.rightMargin: 7

                    hoverMessage: qsTr('Send to channel')

                    lowBound: 0
                    highBound: 99
                }
            }

            Button {
                id: btnGoToChannel
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: channelPickerContainer.right
                    leftMargin: contentMargins
                }

                width: 107
            }

            Button {
                id: btnMute

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: btnGoToChannel.right
                    leftMargin: contentMargins
                }

                width: height

                isToggleButton: true
                pressed: true

                imageSource: pressed ? 'Images/Unmuted.svg' : 'Images/Muted.svg'
                imageWidth: 12
                imageHeight: 12
            }

            Button {
                id: btnSolo

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: btnMute.right
                    leftMargin: contentMargins
                }

                width: height

                isToggleButton: true

                imageSource: 'Images/Solo.svg'
                imageWidth: 12
                imageHeight: 12
            }

            Knob {
                id: volume

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: btnSolo.right
                    leftMargin: contentMargins
                }

                width: height

                min: 0
                max: 100
                value: 80

                hoverMessage: qsTr('Volume')
                units: '%'
            }

            Knob {
                id: pan

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: volume.right
                    leftMargin: contentMargins
                }

                isLeftRightKnob: true

                min: -100
                max: 100
                value: 0

                width: height

                hoverMessage: qsTr('Pan')
                units: '%'
            }

            Rectangle {
                color: Qt.rgba(1, 1, 1, 0.3)

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: pan.right
                    leftMargin: contentMargins
                }

                width: 10

                radius: 1
            }
        }
    }

    // I know the order here is confusing, but this appears on the left. It's
    // last so it renders on top.
    Item {
        id: colorPickerButton

        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        width: 7

        property string color: '#35813F'
        Rectangle {
            anchors.fill: parent
            color: parent.color
            radius: 1
        }
        Rectangle {
            anchors.fill: parent
            color: parent.color
            anchors.leftMargin: 3
        }
    }
}
