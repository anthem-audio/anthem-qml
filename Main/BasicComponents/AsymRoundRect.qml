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

// Rectangle that has a different raidus for different sides
Item {
    id: rect
    enum Direction {
        Horizontal,
        Vertical
    }

    property color color: 'white'
    property int direction: AsymRoundRect.Direction.Horizontal
    // top or left
    property real startRadius: 0
    // bottom or right
    property real endRadius: 0

    Item {
        clip: true
        anchors {
            top: rect.top
            left: rect.left
            bottom: direction === AsymRoundRect.Direction.Horizontal ? rect.bottom : undefined
            right: direction === AsymRoundRect.Direction.Vertical ? rect.right : undefined
        }
        width: direction === AsymRoundRect.Direction.Horizontal ? Math.floor(rect.width * 0.5) : undefined
        height: direction === AsymRoundRect.Direction.Vertical ? Math.floor(rect.height * 0.5) : undefined

        Rectangle {
            anchors.fill: parent
            anchors.bottomMargin: -startRadius

            color: rect.color
            radius: rect.startRadius
        }
    }
    Item {
        clip: true
        anchors {
            top: direction === AsymRoundRect.Direction.Horizontal ? rect.top : undefined
            left: direction === AsymRoundRect.Direction.Vertical ? rect.left : undefined
            bottom: rect.bottom
            right: rect.right
        }

        width: direction === AsymRoundRect.Direction.Horizontal ? Math.ceil(rect.width * 0.5) : undefined
        height: direction === AsymRoundRect.Direction.Vertical ? Math.ceil(rect.height * 0.5) : undefined

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: -endRadius

            color: rect.color
            radius: rect.endRadius
        }
    }
}
