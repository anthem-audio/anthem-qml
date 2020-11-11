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
    id: channelList
    readonly property int channelHeight: 26
    readonly property int channelPadding: 2

    // Each item in this list is just a key that can be used to get
    // the channel info from the engine.
    ListModel {
        id: channels
        ListElement {
            key: 'one'
        }
        ListElement {
            key: 'two'
        }
        ListElement {
            key: 'three'
        }
        ListElement {
            key: 'four'
        }
        ListElement {
            key: 'five'
        }
        ListElement {
            key: 'six'
        }
        ListElement {
            key: 'seven'
        }
    }

    Repeater {
        model: channels
        Channel {
            x: 0
            y: index * (channelHeight + channelPadding)
            width: channelList.width
            height: channelHeight
        }
    }
}
