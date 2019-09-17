import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13
import "BasicComponents"

Window {
    id: mainWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    width: 1300
    height: 768
    property int previousX
    property int previousY
    property bool isMaximized: false
    readonly property int margin: 5

    color: "#454545"

    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: Anthem.undo()
    }

    Shortcut {
        sequence: "Ctrl+Shift+Z"
        onActivated: Anthem.redo()
    }

    Image {
        id: asdf
        source: "Images/pretty.jpg"
        anchors.fill: parent
    }
    FastBlur {
        id: blurredbg
        visible: true
        anchors.fill: asdf
        source: asdf
        radius: 128
    }

    Item {
        id: header
        width: parent.width
        height: 30

        anchors.top: parent.top

        Item {
            id: headerControlsContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: margin
            anchors.leftMargin: margin
            anchors.rightMargin: margin
            height: 20

            TabGroup {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: windowButtonsContainer.left
            }

            // We need a ButtonGroup here, but as of writing this comment, I haven't created one yet.
            //   -- Joshua Wade, Jun 4, 2019

            Rectangle {
                id: windowButtonsContainer
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 28 + 26 + 28

                color: "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.4)
                radius: 2
                antialiasing: true


                Button {
                    id: btnMinimize
                    width: 26
                    anchors.right: spacer1.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    anchors.leftMargin: 1
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1

                    showBorder: false

                    imageSource: "Images/Minimize.svg"
                    imageWidth: 8
                    imageHeight: 8

                    onPress: {
                        mainWindow.showMinimized()
                    }
                }
                Rectangle {
                    id: spacer1
                    width: 1
                    anchors.right: btnMaximize.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    color: Qt.rgba(0, 0, 0, 0.4)
                }
                Button {
                    id: btnMaximize
                    width: 26
                    anchors.right: spacer2.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    anchors.topMargin: 1
                    anchors.bottomMargin: 1

                    showBorder: false

                    imageSource: "Images/Maximize.svg"
                    imageWidth: 8
                    imageHeight: 8

                    onPress: {
                        if (mainWindow.isMaximized)
                            mainWindow.showNormal();
                        else
                            mainWindow.showMaximized();

                        mainWindow.isMaximized = !mainWindow.isMaximized;
                    }
                }
                Rectangle {
                    id: spacer2
                    width: 1
                    anchors.right: btnClose.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1
                    color: Qt.rgba(0, 0, 0, 0.4)
                }
                Button {
                    id: btnClose
                    width: 26
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    anchors.rightMargin: 1
                    anchors.topMargin: 1
                    anchors.bottomMargin: 1

                    showBorder: false

                    imageSource: "Images/Close.svg"
                    imageWidth: 8
                    imageHeight: 8

                    onPress: {
                        mainWindow.close()
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: 28 + 26 + 28 + margin // close buttons width + margin

            onPressed: {
                previousX = mouseX
                previousY = mouseY
            }

            onReleased: {
                if (mainWindow.y + mouseY < 1) {
                    mainWindow.isMaximized = true;
                    mainWindow.showMaximized();
                }
            }

            onMouseXChanged: {
                if (mainWindow.isMaximized) {
                    mainWindow.isMaximized = false;
                    mainWindow.showNormal();
                }

                var dx = mouseX - previousX
                mainWindow.setX(mainWindow.x + dx)
            }

            onMouseYChanged: {
                if (mainWindow.isMaximized) {
                    mainWindow.isMaximized = false;
                    mainWindow.showNormal();
                }

                var dy = mouseY - previousY
                mainWindow.setY(mainWindow.y + dy)
            }
        }
    }

    Item {
        id: mainContentContainer

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerContainer.top

        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.bottomMargin: 5

        ControlsPanel {
            id: controlsPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }

        MainStack {
            anchors.top: controlsPanel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.topMargin: 4
        }
    }

    Item {
        id: footerContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 30
    }

    // Resize right
    MouseArea {
        width: 5

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        cursorShape: Qt.SizeHorCursor

        onPressed: previousX = mouseX

        onMouseXChanged: {
            var dx = mouseX - previousX
            mainWindow.setWidth(parent.width + dx)
            mainWindow.set
        }

    }

    // Resize top
    MouseArea {
        height: 5
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        cursorShape: Qt.SizeVerCursor

        onPressed: previousY = mouseY

        onMouseYChanged: {
            var dy = mouseY - previousY
            mainWindow.setY(mainWindow.y + dy)
            mainWindow.setHeight(mainWindow.height - dy)
        }
    }

    // Resize bottom
    MouseArea {
        height: 5
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        cursorShape: Qt.SizeVerCursor

        onPressed: previousY = mouseY

        onMouseYChanged: {
            var dy = mouseY - previousY
            mainWindow.setHeight(mainWindow.height + dy)
        }
    }

    // Resize left
    MouseArea {
        width: 5
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        cursorShape: Qt.SizeHorCursor

        onPressed: previousX = mouseX

        onMouseYChanged: {
            var dx = mouseX - previousX
            mainWindow.setX(mainWindow.x + dx)
            mainWindow.setWidth(mainWindow.width - dx)
        }
    }
}
