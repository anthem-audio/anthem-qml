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

import QtQuick 2.14
import QtGraphicalEffects 1.14

import "GenericTooltip"
import "../Global"

TooltipWrapper {
    id: wrapper
    content: Item {
        property int id

        width: 130
        height: 45

        Rectangle {
            radius: 6
            color: Qt.rgba(0, 0, 0, 0.72)
            anchors.fill: parent

            Item {
                id: contentSpacer
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: colorPickerMouseArea.left
                    left: parent.left
                }

                Item {
                    id: topSpacer
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: bottomSpacer.top
                    }

                    TextInput {
                        anchors.fill: parent
                        anchors.margins: 6
                        font {
                            pixelSize: parent.height - 12
                            family: Fonts.notoSansRegular.name
                        }
                        color: Qt.hsla(0, 0, 1, 0.8)
                        selectionColor: Qt.hsla(162/360, 0.5, 0.43, 0.5)
                        clip: true
                    }
                }

                Item {
                    id: bottomSpacer
                    height: 12
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        right: parent.right
                        margins: 3
                    }

                    Button {
                        id: btnAccept
                        anchors {
                            top: parent.top
                            right: btnCancel.left
                            rightMargin: 3
                            bottom: parent.bottom
                        }
                        width: parent.height
                        showBackground: false
                        showBorder: false
                        imageSource: "Images/Check.svg"
                        imageWidth: 8
                        imageHeight: 8
                    }

                    Button {
                        id: btnCancel
                        anchors {
                            top: parent.top
                            right: parent.right
                            bottom: parent.bottom
                        }
                        width: parent.height
                        showBackground: false
                        showBorder: false
                        imageSource: "Images/Close.svg"
                        imageWidth: 8
                        imageHeight: 8
                        onPress: {
                            wrapper.close();
                        }
                    }
                }
            }

            Rectangle {
                id: btnColorPicker
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                    margins: 3
                }
                width: 6
                radius: 2
                color:
                        colorPicker.hoverColor !== ''
                        ? colorPicker.hoverColor
                        : "lightblue";


                opacity:
                    colorPickerMouseArea.hovered &&
                        !colorPickerMouseArea.pressed
                    ? 1 : 0.7
            }

            MouseArea {
                property bool hovered: false
                property bool pressed: false

                id: colorPickerMouseArea
                anchors {
                    top: parent.top
                    right: parent.right
                    bottom: parent.bottom
                }
                width: 12
                hoverEnabled: true
                onEntered: hovered = true;
                onExited: hovered = false;
                onPressed: pressed = true;
                onReleased: {
                    pressed = false;

                    colorPicker.open();
                }
            }

            ColorPickerTooltip {
                id: colorPicker
                x: parent.width
            }
        }

        MouseArea {
            anchors.fill:
                    tooltipManager.openItemCount > 1
                ? parent : undefined

            width:
                    tooltipManager.openItemCount < 2
                ? 0 : undefined

            height:
                    tooltipManager.openItemCount < 2
                ? 0 : undefined

            onPressed: {
                colorPicker.close()
            }

            hoverEnabled: true
        }
    }
}
