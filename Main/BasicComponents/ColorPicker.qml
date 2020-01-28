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

Item {
    id: picker
    property real cellSize: 15
    property real cellMargin: 3

    property int cellsPerRow: parseInt(picker.width / (cellSize + cellMargin));
    property int rowCount: parseInt(picker.height / (cellSize + cellMargin));

    property string hoveredColor
    signal colorHovered(string color)
    signal colorSelected(string color)

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onExited: {
            colorHovered('');
        }

        Column {
            anchors.fill: parent
            Repeater {
                model: rowCount

                Row {
                    property int rowIndex: index
                    height: cellSize + cellMargin
                    Repeater {
                        model: cellsPerRow
                        Item {
                            property int columnIndex: index
                            width: cellSize + cellMargin
                            height: cellSize + cellMargin
                            Rectangle {
                                width: cellSize
                                height: cellSize
                                color:
                                    Qt.hsla(
                                        columnIndex / cellsPerRow,
                                        0.43,
                                        (1 - rowIndex / rowCount) * 0.7 + 0.05,
                                        1
                                    )
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        hoveredColor = parent.color;
                                        colorHovered(hoveredColor);
                                    }
                                    propagateComposedEvents: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
