import QtQuick 2.13

import "../Global"

Item {
    id: control
    property int value: 0
    property int highBound
    property int lowBound
    property int alignment: Text.AlignRight

    signal valueChangeCompleted(int value);

    Text {
        id: pitchLabel
        text: qsTr(value.toString())
        font.family: Fonts.notoSansRegular.name
        font.pointSize: 8
        horizontalAlignment: alignment
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
        color: "#1ac18f"
    }

    ControlMouseArea {
        id: mouseArea

        anchors.fill: parent

        property int accumulator: 0
        property int slownessMultiplier: 12

        // If both highBound and lowBound are unset, they will both be 0
        property bool hasBound: highBound != lowBound

        onDrag: {
            accumulator += deltaY

            while(Math.abs(accumulator) > slownessMultiplier) {
                if (accumulator > slownessMultiplier) {
                    if (!(hasBound && value >= highBound))
                        value++;
                    accumulator -= slownessMultiplier;
                }
                else if (accumulator < -slownessMultiplier) {
                    if (!(hasBound && value <= lowBound))
                        value--;
                    accumulator += slownessMultiplier;
                }
            }
        }

        onDragEnd: {
            control.valueChangeCompleted(control.value);
        }
    }
}
