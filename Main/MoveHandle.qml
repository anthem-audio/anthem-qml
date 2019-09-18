import QtQuick 2.0

Item {
    property var mainWindow

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
