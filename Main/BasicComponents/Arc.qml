/*
    Copyright (C) 2018 Rob van den Berg <rghvdberg at gmail dot org>
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
    id: root

    property int size: Math.min(width, height) // The size of the circle in pixels
    property real arcBegin: 0                  // Start angle in degrees
    property real arcEnd: 270                  // End angle in degrees
    property real arcOffset: 0                 // Offset rotation in degrees
    property bool isPie: false                 // Paint a pie instead of an arc
    property bool showBackground: false        // Show a full circle as a background of the arc
    property real lineWidth: 2                 // Width of the arc line
    property string colorCircle: "#CC3333"
    property string colorBackground: "#779933"
    property bool roundLineCaps: false

//    property alias beginAnimation: animationArcBegin.enabled
//    property alias endAnimation: animationArcEnd.enabled
//    property int animationDuration: 200

    onArcBeginChanged: canvas.requestPaint()
    onArcEndChanged: canvas.requestPaint()
    onLineWidthChanged: canvas.requestPaint()

//    Behavior on arcBegin {
//       id: animationArcBegin
//       enabled: true
//       SpringAnimation { spring: 2; damping: 0.2 }
//    }

//    Behavior on arcEnd {
//       id: animationArcEnd
//       enabled: true
//       SpringAnimation { spring: 2; damping: 0.2 }
//    }

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: -90 + parent.arcOffset

        onPaint: {
            var ctx = getContext('2d');
            var x = width / 2;
            var y = height / 2;
            var start = Math.PI * (parent.arcBegin / 180);
            var end = Math.PI * (parent.arcEnd / 180);
            ctx.reset();
            if (roundLineCaps) ctx.lineCap = 'round';

            if (root.isPie) {
                if (root.showBackground) {
                    ctx.beginPath();
                    ctx.fillStyle = root.colorBackground;
                    ctx.moveTo(x, y);
                    ctx.arc(x, y, width / 2, 0, Math.PI * 2, false);
                    ctx.lineTo(x, y);
                    ctx.fill();
                }
                ctx.beginPath();
                ctx.fillStyle = root.colorCircle;
                ctx.moveTo(x, y);
                ctx.arc(x, y, width / 2, start, end, false);
                ctx.lineTo(x, y);
                ctx.fill();
            } else {
                if (root.showBackground) {
                    ctx.beginPath();
                    ctx.arc(x, y, (width / 2) - parent.lineWidth / 2, 0, Math.PI * 2, false);
                    ctx.lineWidth = root.lineWidth;
                    ctx.strokeStyle = root.colorBackground;
                    ctx.stroke();
                }
                ctx.beginPath();
                ctx.arc(x, y, (width / 2) - parent.lineWidth / 2, start, end, false);
                ctx.lineWidth = root.lineWidth;
                ctx.strokeStyle = root.colorCircle;
                ctx.stroke();
            }
        }
    }
}
