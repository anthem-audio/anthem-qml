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
    property real value: 50
    property real tick: 1
    property real speedMultiplier: 0.3

    // List of values for the knob to 'pause' at. Expects
    // a javascript list.
    property var  pauses: isLeftRightKnob ? [0] : []

    property string hoverMessage: ''
    property string units: ''

    color: "transparent"
    border.width: state.shrinkCenter ? 3 : 2
    border.color: colors.white_7
    radius: width * 0.5

    Behavior on border.width {
        SpringAnimation { spring: state.spring; damping: state.damping }
    }

    QtObject {
        id: state
        property bool isHovered: false
        property bool isActive: mouseArea.isDragActive
        property bool shrinkCenter: isHovered || isActive
        property real spring: 15
        property real damping: 2
        property real accumulator: 0
        property bool showCursor:
            (isLeftRightKnob && Math.abs(value) < tick * 0.1) ||
            (!isLeftRightKnob && Math.abs(value - min) < tick * 0.1)
        property var pauses: knob.pauses.sort()
        property bool isPaused: false
        property real pauseThreshold: 15 * tick
        property real rotationAngle: value * 360 / (max - min)
        property real arcRoundnessCorrection:
            ((state.isHovered || state.isActive) ? 1.75 : 1) * 360 / (Math.PI * knob.width)
        Behavior on arcRoundnessCorrection {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    Arc {
        anchors.fill: parent
        lineWidth: state.shrinkCenter ? 3 : 2
        colorCircle: colors.main
        roundLineCaps: true

        // If you think this math is confusing then uhh
        // yeah me too
        arcOffset: (isLeftRightKnob ? (value < 0 ? state.rotationAngle : 0) : 180) + ((isLeftRightKnob && value < 0) ? 0 : 1) * state.arcRoundnessCorrection
        arcBegin: 0
        property real endTarget: Math.abs(state.rotationAngle) - state.arcRoundnessCorrection
        arcEnd: endTarget < arcBegin ? arcBegin : endTarget

        Behavior on lineWidth {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    Rectangle {
        color: colors.white_12
        anchors.fill: parent
        anchors.margins: state.shrinkCenter ? 5 : 4
        radius: width * 0.5

        Behavior on anchors.margins {
            SpringAnimation { spring: state.spring; damping: state.damping }
        }
    }

    Item {
        anchors.fill: parent
        transform: Rotation {
            origin.x: knob.width * 0.5
            origin.y: knob.height * 0.5
            angle: state.rotationAngle
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: isLeftRightKnob ? undefined : parent.bottom
            anchors.top: isLeftRightKnob ? parent.top : undefined
            property real distanceFromEdge: state.shrinkCenter ? 5 : 4
            anchors.bottomMargin: isLeftRightKnob ? undefined : distanceFromEdge
            anchors.topMargin: isLeftRightKnob ? distanceFromEdge : undefined
            width: 2
            height: 6
            radius: 1
            color: '#c4c4c4'
            opacity: knob.width < 25 && state.shrinkCenter ? 0 : 1

            Behavior on distanceFromEdge {
                SpringAnimation { spring: state.spring; damping: state.damping }
            }
            Behavior on opacity {
                SpringAnimation { spring: state.spring; damping: state.damping }
            }
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
            if (state.isPaused) {
                if (state.accumulator > state.pauseThreshold || state.accumulator < -state.pauseThreshold) {
                    state.accumulator = delta;
                    tempValue += delta;
                    state.isPaused = false;
                }
            }
            else if (Math.round(value + state.accumulator) !== value) {
                tempValue += state.accumulator;
                state.accumulator = 0;
            }

            if (tempValue < min) {
                state.accumulator = tempValue - min;
                tempValue = min;
            }
            else if (tempValue > max) {
                state.accumulator = tempValue - max;
                tempValue = max;
            }
            else if (!state.isPaused && state.pauses.length > 0) {
                let left = null;
                let right = null;
                for (let pause of state.pauses) {
                    right = pause;
                    if (pause > value) {
                        break;
                    }
                    left = right;
                }
                if (left === right) {
                    right = null;
                }

                if (right !== null && value !== right && tempValue > right) {
                    state.isPaused = true;
                    state.accumulator = -state.pauseThreshold;
                    value = right;
                    return;
                }
                else if (left !== null && value !== left && tempValue < left) {
                    state.isPaused = true;
                    state.accumulator = state.pauseThreshold;
                    value = left;
                    return;
                }
            }

            if (!state.isPaused && value !== tempValue) {
                value = tempValue;
            }

            globalStore.statusMessage = `${hoverMessage}: ${Math.round(value / tick) * tick}${units}`
        }

        onDragEnd: {
            state.accumulator = 0;
            state.isPaused = false;
            globalStore.statusMessage = '';
        }
    }
}
