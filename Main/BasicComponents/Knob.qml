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
import QtQuick.Shapes 1.15

Rectangle {
    id: knob

    property bool isLeftRightKnob: false

    property real min: 0
    property real max: 100
    property real value: 75
    property real tick: 1
    property real speedMultiplier: 0.3

    color: "transparent"
    border.width: 1
    border.color: Qt.rgba(0, 0, 0, 0.4)
    radius: width * 0.5

    QtObject {
        id: state
        property bool isHovered: false
        property bool isActive: mouseArea.isDragActive
        property bool shrinkCenter: isHovered || isActive
        property real spring: 15
        property real damping: 2
        property real accumulator: 0
        property bool showCursor:
            (isLeftRightKnob && Math.abs(value) < tick * 0.1)
            || Math.abs(value - min) < tick * 0.1
    }

    Arc {
        anchors.fill: parent
        anchors.margins: 1
        lineWidth: state.shrinkCenter ? 3 : 2
        colorCircle: '#1BC18F'

        property real degrees: value * 360 / (max - min)

        // If you think this math is confusing then uhh
        // yeah me too
        arcOffset: isLeftRightKnob ? (value < 0 ? degrees : 0) : 180
        arcBegin: 0
        arcEnd: Math.abs(degrees)

        Behavior on lineWidth {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    Rectangle {
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.4)
        anchors.fill: parent
        anchors.margins: state.shrinkCenter ? 4 : 3
        radius: width * 0.5

        Behavior on anchors.margins {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    GradientBorder {
        anchors.fill: parent
        anchors.margins: state.shrinkCenter ? 5 : 4
        radius: width * 0.5
        boostBrightness: true
        opacity: state.isActive ? 0.5 : 1

        Behavior on anchors.margins {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
        Behavior on opacity {
            SpringAnimation { spring: state.spring * 2; damping: state.damping }
        }
    }

    Rectangle {
        color: Qt.rgba(1, 1, 1)
        opacity: state.isActive ? 0.06 : 0.12
        anchors.fill: parent
        anchors.margins: state.shrinkCenter ? 6 : 5
        radius: width * 0.5

        Behavior on anchors.margins {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
        Behavior on opacity {
            SpringAnimation { spring: state.spring * 2; damping: state.damping }
        }
    }

    Rectangle {
        visible: state.showCursor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: isLeftRightKnob ? undefined : parent.bottom
        anchors.top: isLeftRightKnob ? parent.top : undefined
        property real distanceFromEdge: state.shrinkCenter ? 7 : 6
        anchors.bottomMargin: isLeftRightKnob ? undefined : distanceFromEdge
        anchors.topMargin: isLeftRightKnob ? distanceFromEdge : undefined
        width: 2
        height: 2
        radius: 1
        color: Qt.rgba(1, 1, 1, 0.65)
        opacity: knob.width < 25 && state.shrinkCenter ? 0 : 1

        Behavior on distanceFromEdge {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
        Behavior on opacity {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    ControlMouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            state.isHovered = true;
        }
        onExited: {
            state.isHovered = false;
        }

        onDrag: {
            const delta = deltaY * speedMultiplier;

            let tempValue = value;

            state.accumulator += delta;
            if (Math.round(value + state.accumulator) !== value) {
                tempValue += state.accumulator;
                state.accumulator = 0;
            }

            if (tempValue < min) {
                state.accumulator = tempValue - min;
                tempValue = min;
            }

            if (tempValue > max) {
                state.accumulator = tempValue - max;
                tempValue = max;
            }

            if (value !== tempValue)
                value = tempValue;
        }

        onDragEnd: {
            state.accumulator = 0;
        }
    }
}
