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

Item {
    TextEdit {
        id: textEdit
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.8)
        selectionColor: Qt.hsla(162/360, 0.5, 0.43, 1)
        wrapMode: TextEdit.Wrap

        onTextChanged: {
            Anthem.setNotes(text);
        }

        Connections {
            target: mainWindow
            function onFlush() {
                textEdit.text = Anthem.getNotes();
            }
        }
    }
}
