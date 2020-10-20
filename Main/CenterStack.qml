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
import QtQuick.Controls 2.14
import "BasicComponents"

SplitView {
    orientation: Qt.Vertical
    property bool showEditors

    Panel {
        SplitView.fillHeight: true
        SplitView.minimumHeight: 250

        ArrangerStack {
            anchors.fill: parent
            anchors.margins: 3
        }
    }

    Panel {
        implicitHeight: 350
        SplitView.minimumHeight: 250
        visible: showEditors
    }

    handle: Rectangle {
        implicitWidth: this.width
        implicitHeight: 4

        color: "transparent"
    }
}
