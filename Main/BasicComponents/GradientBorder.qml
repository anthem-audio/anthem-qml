import QtQuick 2.9
import QtGraphicalEffects 1.0

Rectangle {
    anchors.centerIn: parent
    id: root
    property Gradient borderGradient: borderGradient
    property int borderWidth: 1
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
           position: 0.000
           color: Qt.rgba(1, 1, 1, 0.1)
        }
        GradientStop {
            position: 1
            color: Qt.rgba(0,0,0,0)
        }

    }

    Component {
        id: gradientborder
        Item {
            Rectangle {
                id: borderFill
                anchors.fill: parent
                gradient: borderGradient
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
