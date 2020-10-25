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
    property int instanceID;
    property string selectedColor: ''
    property string defaultSelectedColor: colors.main
    property string defaultName: '';

    signal accepted(string name, string color)
    signal rejected()

    onAccepted: {
        close();
    }

    Keys.onEscapePressed: {
        rejected();
    }

    onOpened: {
        instanceID = id;

        selectedColor = defaultSelectedColor;

        let renameInstance = tooltipManager.get(id);

        let input = renameInstance
            .children[0] // Rectangle
            .children[0] // contentSpacer
            .children[0] // topSpacer
            .children[0] // input

        if (defaultName !== '') {
            input.text = defaultName;
        }

//        input.forceActiveFocus();
        input.focus = true;
        input.selectAll();
    }

    content: MouseArea {
        hoverEnabled: true;

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
                        id: input
                        anchors.fill: parent
                        anchors.margins: 6
                        font {
                            pixelSize: parent.height - 12
                            family: Fonts.notoSansRegular.name
                        }
                        color: Qt.hsla(0, 0, 1, 0.8)
                        selectionColor: colors.main
                        clip: true
                        onAccepted: {
                            wrapper.accepted(text, selectedColor);
                        }
                        Keys.onEscapePressed: {
                            rejected();
                            close();
                        }
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
                        imageSource: "Images/Check.svg"
                        imageWidth: 8
                        imageHeight: 8
                        onClicked: {
                            accepted(input.text, selectedColor);
                        }
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
                        imageSource: "Images/icons/small/close.svg"
                        imageWidth: 8
                        imageHeight: 8
                        onClicked: {
                            rejected();
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
                        : selectedColor;


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
                    input.focus = false;
                    colorPicker.focus = true;
                }
            }

            ColorPickerTooltip {
                id: colorPicker
                x: parent.width

                onColorSelected: {
                    btnColorPicker.color = color;
                    selectedColor = color;
                    colorPicker.close();
                }

                onClosed: {
                    input.focus = true;
                }
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
