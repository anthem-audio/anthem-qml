import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../Global"

Item {
    id: button

    property bool   showBorder: true
    property bool   isPressed: false
    property bool   isToggleButton: false

    property bool   hasMenuIndicator: false

    property string imageSource: ""
    property real   imageWidth: 1
    property real   imageHeight: 1

    property string textContent: ""

    QtObject {
        id: buttonProps
        property bool isHoverActive: false
        property bool isMouseDown: false
    }

    signal press()

    Rectangle {
        id: border

        visible: showBorder

        anchors.fill: parent

        color: "transparent"

        radius: 2

        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.4)
    }

    Rectangle {
        id: inside

        anchors.fill: parent
//        anchors.margins: showBorder ? 2 : 1
        anchors.margins: showBorder ? 1 : 0

        radius: 1

        QtObject {
            id: insideProps

            property real opacity:
                (
                    isToggleButton ?
                               (isPressed ? (buttonProps.isMouseDown ? 0.8 : 1) :
                                    (buttonProps.isMouseDown ? 0.09 :
                                        (buttonProps.isHoverActive ? 0.17 : 0.12)
                                    )
                               )
                    :
                        (isPressed ? 0.09 :
                                    (buttonProps.isHoverActive ? 0.17 : 0.12)
                        )
                )

            property bool hasHighlightColor: buttonProps.isPressed ? true : false
        }

        property real h: 162 / 360 // change to be dynamic based on user settings
        property real s: isToggleButton && isPressed ? 0.5 : 0
        property real l: isToggleButton && isPressed ? 0.43 : 100
        color: Qt.hsla(h, s, l, insideProps.opacity)

    }

    GradientBorder {
        id: highlight

        anchors.fill: parent

        anchors.margins: showBorder ? 1 : 0

        borderWidth: 1
    }

    Rectangle {
        id: btnCorner
        color: 'transparent'
        anchors.fill: parent
        border.color: Qt.rgba(1, 1, 1, buttonProps.isHoverActive && !buttonProps.isMouseDown ? 1 : 0.7)
        anchors.margins: 1
        radius: 1
        visible: false
    }

    Text {
        id: text
        text: qsTr(textContent)
        font: Fonts.notoSansRegular.name
        anchors.centerIn: parent
        property int colorVal: isToggleButton && isPressed ? 0 : 1
        color: Qt.rgba(colorVal, colorVal, colorVal, 1)
        opacity: buttonProps.isHoverActive && !buttonProps.isMouseDown ? 1 : (colorVal == 1 ? 0.7 : 0.6)
    }

    Image {
        id: icon
        // If the source is defined, use it. Otherwise, use a transparent 1-pixel PNG.
        source: imageSource != "" ? "../" + imageSource : "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        width: imageWidth
        height: imageHeight
        anchors.centerIn: parent
        sourceSize.width: imageWidth
        sourceSize.height: imageHeight
        visible: false
    }
    ColorOverlay {
        anchors.fill: icon
        source: icon
        property int colorVal: isToggleButton && isPressed ? 0 : 1
        color: Qt.rgba(colorVal, colorVal, colorVal, 1)
        opacity: buttonProps.isHoverActive && !buttonProps.isMouseDown ? 1 : (colorVal == 1 ? 0.7 : 0.6)
    }

    Rectangle {
        id: btnCornerMask

        anchors.fill: parent
        anchors.margins: 1
        color: 'transparent'

        Rectangle {
            color: 'white'
            width: 5
            height: 5
            anchors.bottom: parent.bottom
            anchors.right: parent.right
        }

        visible: false
    }

    OpacityMask {
        anchors.fill: btnCorner
        source: btnCorner
        maskSource: btnCornerMask
        visible: hasMenuIndicator
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.press()

        onPressed: {
            if (!isToggleButton)
                isPressed = true
            buttonProps.isMouseDown = true
        }

        onReleased: {
            if (!isToggleButton)
                isPressed = false
            else
                isPressed = !isPressed
            buttonProps.isMouseDown = false
        }

        property alias hoverActive: buttonProps.isHoverActive

        hoverEnabled: true
        onEntered: hoverActive = true
        onExited: hoverActive = false
    }
}
