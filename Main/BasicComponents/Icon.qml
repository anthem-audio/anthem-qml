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
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15

Item {
    id: icon
    property string imageSource: ''
    property real   imageWidth: width
    property real   imageHeight: height

    property color  color: 'white'

    Image {
        id: image
        // If the source is defined, use it. Otherwise, use a transparent 1-pixel PNG.
        source:
            imageSource != ''
                ? '../' + imageSource
                : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII='
        width: imageWidth + 2
        height: imageHeight + 2
        anchors.centerIn: parent
        sourceSize.width: imageWidth
        sourceSize.height: imageHeight
        fillMode: Image.Pad
        visible: false
        sourceClipRect:
            Qt.rect(
                -1,
                -1,
                imageWidth * Screen.devicePixelRatio + 2,
                imageHeight * Screen.devicePixelRatio + 2
            )
    }
    ColorOverlay {
        anchors.fill: image
        source: image
        visible: true
        color: icon.color
    }
}
