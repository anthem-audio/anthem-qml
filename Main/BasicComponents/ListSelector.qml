/*
    Copyright (C) 2019 Joshua Wade

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
import "../BasicComponents"
import "../Menus"
import "../Global"

Button {
    /*
     * Data format:
     * [
     *   {
     *     id: (any),
     *     displayName: (string),
     *   },
     * ]
     */
    property var listItems: []
    property bool allowNoSelection: false
    readonly property var selectedItem: state.selectedItem
    readonly property int selectedItemIndex: state.selectedItemIndex
    readonly property string selectedItemDisplayName: selectedItem.displayName
    property real textPixelSize: 11
    property real menuMaxWidth

    QtObject {
        id: state
        property var selectedItem: ({displayName: qsTr('(none)')})
        property int selectedItemIndex: -1
    }

    function selectItem(index) {
        state.selectedItemIndex = index;
        state.selectedItem =
            selectedItemIndex >= 0
                ? listItems[index]
                : { displayName: qsTr('(none)') };
    }

    clickOnMouseDown: true

    onClicked: {
        let processedItems = [];

        if (allowNoSelection) {
            processedItems.push({
                text: qsTr('(none)'),
                onTriggered: () => {
                    state.selectedItem = {displayName: qsTr('(none)')};
                    state.selectedItemIndex = -1;
                },
            });
        }

        for (let i = 0; i < listItems.length; i++) {
            let item = listItems[i];
            let newItem = {};

            newItem.text = item.displayName;
            newItem.onTriggered = () => {
                state.selectedItem = item;
                state.selectedItemIndex = i;
            }

            processedItems.push(newItem);
        }

        menu.menuItems = processedItems;
        menu.open();
    }

    hasMenuIndicator: true

    Text {
        text: selectedItem.displayName ? qsTr(selectedItem.displayName) : qsTr("(none)")
        font.family: Fonts.main.name
        font.pixelSize: textPixelSize
        anchors {
            left: parent.left
            right: parent.right
            margins: 4
            verticalCenter: parent.verticalCenter
        }
        elide: Text.ElideMiddle
        color: colors.main
    }

    Menu {
        id: menu
        maxHeight: mainWindow.height
        menuY: parent.height
        minWidth: parent.width
        maxWidth: menuMaxWidth
    }
}
