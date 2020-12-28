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

// Project-level shortcuts live here. I have tried a number of different
// ways of getting shortcuts to work in the Project component, but they
// all seem to fail after the second project is added.

import QtQuick 2.15

Item {
    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: {
            undo();
        }
    }

    Shortcut {
        sequence: "Ctrl+Shift+Z"
        onActivated: {
            redo();
        }
    }

    signal undo()
    signal redo()
}
