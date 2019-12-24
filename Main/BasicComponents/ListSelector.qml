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

import QtQuick 2.13
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
    property var selectedItem: {id: -1}
    property real textPixelSize: 11
    property real _hue: 162 / 360

    onPress: {
        let processedItems = [];

        for (let item of listItems) {
            let newItem = {};

            newItem.text = item.displayName;
            newItem.onTriggered = () => {
                selectedItem = item;
            }

            processedItems.push(newItem);
        }

        menu.menuItems = processedItems;
        menu.open();
    }

    hasMenuIndicator: true

    Text {
        text: selectedItem.displayName ? qsTr(selectedItem.displayName) : qsTr("(none)")
        font.family: Fonts.notoSansRegular.name
        font.pixelSize: textPixelSize
        anchors.left: parent.left
        anchors.margins: 4
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.hsla(_hue, 0.5, 0.43, 1);
    }

    Menu {
        id: menu
        maxHeight: mainWindow.height
        menuY: parent.height
        minWidth: parent.width
    }
}
