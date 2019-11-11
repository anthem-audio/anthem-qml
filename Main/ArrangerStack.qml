/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.13
import QtQuick.Controls 2.13
import "BasicComponents"

SplitView {
    orientation: Qt.Horizontal

    Rectangle {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 500
        color: "transparent"
        SplitView.fillWidth: true
    }

    Rectangle {
        implicitWidth: 145
        SplitView.preferredWidth: 145
        SplitView.maximumWidth: 145
        SplitView.minimumWidth: 145
        color: "transparent"
    }

    Rectangle {
        SplitView.minimumWidth: 50
        color: "transparent"
    }

    handle: Rectangle {
        implicitWidth: 3
        implicitHeight: this.height

        color: Qt.rgba(1, 1, 1, 0.2)
    }
}
