import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Shapes 1.13
import "BasicComponents"

Window {
    id: mainWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    width: 1024
    height: 768
//    title: qsTr("Hello World")
    property int previousX
    property int previousY
    property bool isMaximized: false
    readonly property int margin: 5

    color: "#454545"

    Rectangle {
        id: header
        width: parent.width
        height: 30
        color: "transparent"

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

            // We need a ButtonGroup here, but as of writing this comment, I haven't created one yet.
            //   -- Joshua Wade, Jun 4, 2019

            Rectangle {
                id: buttonContainer
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

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 5

                        height: 1
                        width: 8
                        radius: 1

                        color: Qt.rgba(1, 1, 1, 0.65)
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

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5

                        width: 8
                        radius: 1

                        color: "transparent"

                        border.color: Qt.rgba(1, 1, 1, 0.65)
                        border.width: 1
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

                    Shape {
                        anchors.bottom: parent.bottom
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 5
                        anchors.topMargin: 5

                        width: 8

                        ShapePath {
                            startX: 0.5; startY: 0.5
                            PathLine { x: 7.5; y: 7.5 }

                            strokeWidth: 1
                            strokeColor: Qt.rgba(1, 1, 1, 0.65)
                        }

                        ShapePath {
                            startX: 7.5; startY: 0.5
                            PathLine { x: 0.5; y: 7.5 }

                            strokeWidth: 1
                            strokeColor: Qt.rgba(1, 1, 1, 0.65)
                        }
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: 28 + 26 + 28 + margin // close buttons width + margin

            Rectangle {
                anchors.fill: parent
                color: "red"
            }

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
