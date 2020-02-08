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
import "../../BasicComponents"
import "../../Menus"

Item {
    id: patternEditor
    anchors.margins: 3

    property var patterns: ({})

    Connections {
        target: PatternPresenter
        onPatternAdd: {
            patterns[id] = {
                displayName: PatternPresenter.getPatternName(id),
                color: Qt.rgba(1, 1, 0, 1)
            };
            updatePatternList();
        }
        onPatternRemove: {
            delete patterns[id];
            updatePatternList();
        }
        onFlushPatterns: {
            patterns = newPatterns;
            updatePatternList();
        }
    }

    function updatePatternList() {
        const lastSelectedId = patternSelector.selectedItem.id;

        // If this starts as false then it can't become true
        let wasLastSelectedIdRemoved = patternSelector.selectedItem.id !== undefined;

        // Repopulate list items
        patternSelector.listItems = Object.keys(patterns).map((id, index) => {
            wasLastSelectedIdRemoved =
                wasLastSelectedIdRemoved && !(id === lastSelectedId);
            return { id, displayName: patterns[id].displayName };
        });

        // If the previously selected list item was removed, select a new item.
        if (wasLastSelectedIdRemoved) {
            patternSelector.selectItem(
                patternSelector.selectedItemIndex <
                    patternSelector.listItems.length
                    ? patternSelector.selectedItemIndex
                    : patternSelector.listItems.length - 1
            );
        }
    }

    Item {
        id: topRowContainer
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: 20

        Button {
            id: menuButton
            anchors.top: parent.top
            anchors.left: parent.left
            height: parent.height
            width: parent.height

            imageSource: "Images/Hamburger.svg"
            imageWidth: 8
            imageHeight: 9

            onPress: {
                patternEditorMenu.open();
            }
        }

        Menu {
            id: patternEditorMenu
            menuX: 0
            menuY: menuButton.height

            menuItems: [
                {
                    text: 'New pattern',
                    hoverText: 'Create a new pattern',
                    onTriggered: () => {
                        addPatternTooltip.open();
                    }
                }
            ]
        }

        ListSelector {
            id: patternSelector

            anchors {
                left: menuButton.right
                leftMargin: 3
                top: parent.top
                bottom: parent.bottom
            }
            width: 169
            menuMaxWidth: 200

            allowNoSelection: true
            hoverMessage: qsTr("Select a pattern to edit...")

            listItems: []
        }

        RenameTooltip {
            id: addPatternTooltip
            y: parent.height + 3
            defaultName: 'Pattern 1';
            onAccepted: {
                PatternPresenter.createPattern(name, color);
            }
        }
    }
}
