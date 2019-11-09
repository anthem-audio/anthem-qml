import QtQuick 2.13

import "../Global"

Item {
    id: control
    property real   value: 0
    property int    _valueSource
    property real   highBound
    property real   lowBound
    property real   step: 1
    property real   smallestIncrement: step
    property real   speedMultiplier: 1
    property int    decimalPlaces: 0
    property int    alignment: Text.AlignRight
    property var    fontFamily: Fonts.sourceCodeProSemiBold.name
    property int    fontPixelSize: 11
    property var    acceptedValues: []
    property string hoverMessage: ""
    property string units: ""

    property int    _scaledHighBound: Math.round(highBound * _valueScale);
    property int    _scaledLowBound: Math.round(lowBound * _valueScale);
    property bool   _shouldUseAcceptedValues: acceptedValues.length !== 0
    property var    _acceptedValueIndex: _shouldUseAcceptedValues ? acceptedValues.indexOf(value) : undefined;
    property bool   _dragActive: false
    property bool   _hoverActive: false
    property real   _valueScale: 1/smallestIncrement
    property real   _stepsPerIncrement: step/smallestIncrement

    signal valueChangeCompleted(real value)

    Component.onCompleted: {
        _valueSource = Math.round(value * _valueScale);
    }

    onValueChanged: {
        _valueSource = Math.round(value * _valueScale);
    }

    Text {
        id: digitLabel
        text: qsTr(value.toFixed(decimalPlaces))

        onTextChanged: {
            if (_dragActive || _hoverActive)
                Anthem.displayStatusMessage(`${hoverMessage}: ${text} ${units}`);
        }

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
            let delta = ((deltaY) * 0.07 * speedMultiplier * _stepsPerIncrement) + remainder;
            let roundedDelta = Math.round(Math.round(delta / _stepsPerIncrement) * _stepsPerIncrement);
            remainder = delta - roundedDelta;
            let newValueSource = _valueSource + roundedDelta;

            if (_shouldUseAcceptedValues) {
                _acceptedValueIndex += Math.round(roundedDelta);
                if (_acceptedValueIndex < 0)
                    _acceptedValueIndex = 0;
                else if (_acceptedValueIndex >= acceptedValues.length)
                    _acceptedValueIndex = acceptedValues.length - 1;
                value = acceptedValues[_acceptedValueIndex]
            }
            else if (hasBound) {
                if (newValueSource < _scaledLowBound) {
                    remainder += newValueSource - _scaledLowBound;
                    _valueSource = _scaledLowBound;
                }
                else if (newValueSource > _scaledHighBound) {
                    remainder += newValueSource - _scaledHighBound;
                    _valueSource = _scaledHighBound;
                }
                else {
                    _valueSource = newValueSource;
                }
                value = _valueSource * smallestIncrement;
            }
            else {
                _valueSource = newValueSource;
                value = _valueSource * smallestIncrement;
            }

            _dragActive = true;
        }

        onDragEnd: {
            remainder = 0;
            control.valueChangeCompleted(control.value);
            _dragActive = false;
            Anthem.displayStatusMessage(hoverMessage);
        }

        hoverEnabled: true
        onEntered: {
            _hoverActive = true;
            if (!_dragActive && hoverMessage !== "")
                Anthem.displayStatusMessage(hoverMessage);
        }
        onExited: {
            _hoverActive = false;
            if (!_dragActive)
                Anthem.displayStatusMessage("");
        }
    }
}
