import QtQuick 2.13
import QtQuick.Window 2.13

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
        height: 40
        color: "transparent"

        anchors.top: parent.top

        Rectangle {
            id: headerControlsContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: margin
            anchors.leftMargin: margin
            anchors.rightMargin: margin
            height: 20

            color: "blue"
        }

        MouseArea {
            anchors.fill: parent

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
