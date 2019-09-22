import QtQuick 2.13
import QtGraphicalEffects 1.13

Rectangle {
    anchors.centerIn: parent
    id: root
    property Gradient borderGradient: borderGradient
    property int borderWidth: 1
    property real hue: 162 / 360;
    property bool showHighlightColor: false;
    implicitWidth: 26
    implicitHeight: 26
    radius: 1
    color:"transparent"

    Loader {
        id: loader
        width: root.width
        height: root.height
        anchors.centerIn: parent
        active: borderGradient
        sourceComponent: gradientborder
    }

    Gradient {
        id: borderGradient
        GradientStop {
           position: 0
           color: Qt.rgba(1, 1, 1, 0.1)
        }
        GradientStop {
            position: 1
            color: Qt.rgba(0,0,0,0)
        }
    }

    Gradient {
        id: highlightGradient
        GradientStop {
           position: 0
           color: Qt.hsla(hue, 0.5, 0.43, 1)
        }
        GradientStop {
            position: 1
            color: Qt.hsla(hue, 0.5, 0.43, 1)
        }
    }

    Component {
        id: gradientborder
        Item {
            Rectangle {
                id: borderFill
                anchors.fill: parent
                gradient: showHighlightColor ? highlightGradient : borderGradient
                visible: false
            }

            Rectangle {
                id: mask
                radius: root.radius
                border.width: root.borderWidth
                anchors.fill: parent
                color: 'transparent'
                visible: false// otherwise a thin border might be seen.
            }

            OpacityMask {
                id: opM
                anchors.fill: parent
                source: borderFill
                maskSource: mask
            }
        }
    }
}
