import QtQuick 2.13

import "../Global"

Item {
    id: control
    property real value: 0
    property real highBound
    property real lowBound
    property real step: 1
    property real speedMultiplier: 1
    property int  decimalPlaces: 0
    property int  alignment: Text.AlignRight
    property var  fontFamily: Fonts.sourceCodeProSemiBold.name
    property int  fontPixelSize: 11
    property var  acceptedValues: []
    property bool shouldUseAcceptedValues: acceptedValues.length !== 0
    property var  acceptedValueIndex: shouldUseAcceptedValues ? acceptedValues.indexOf(value) : undefined;

    signal valueChangeCompleted(real value)

    function roundToPrecision(x, precision) {
        var y = + x + precision / 2;
        return y - (y % precision);
    }

    Text {
        id: pitchLabel
        text: qsTr(value.toFixed(decimalPlaces))
        font.family: fontFamily
        font.pixelSize: fontPixelSize
        horizontalAlignment: alignment
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        color: "#1ac18f"
    }

    ControlMouseArea {
        id: mouseArea

        anchors.fill: parent

        property real remainder

        // If highBound and lowBound are unset, they will both be 0
        property bool hasBound: highBound != lowBound

        onDrag: {
            let delta = ((deltaY) * 0.08 * speedMultiplier * step) + remainder;
            let roundedDelta = roundToPrecision(delta, step);
            remainder = delta - roundedDelta;
            let newValue = value + roundedDelta;

            if (shouldUseAcceptedValues) {
                acceptedValueIndex += Math.round(roundedDelta);
                if (acceptedValueIndex < 0)
                    acceptedValueIndex = 0;
                else if (acceptedValueIndex >= acceptedValues.length)
                    acceptedValueIndex = acceptedValues.length - 1;
                value = acceptedValues[acceptedValueIndex]
            }
            else if (hasBound) {
                if (newValue < lowBound) {
                    remainder += newValue - lowBound;
                    value = lowBound;
                }
                else if (newValue > highBound) {
                    remainder += newValue - highBound;
                    value = highBound;
                }
                else {
                    value = newValue;
                }
            }
            else {
                value = newValue;
            }
        }

        onDragEnd: {
            remainder = 0;
            control.valueChangeCompleted(control.value);
        }
    }
}
