import QtQuick 2.0

Item {
    property var window

    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 28 + 26 + 28 + margin // close buttons width + margin

        onPressed: {
            previousX = mouseX
            previousY = mouseY
        }

        onReleased: {
            if (window.y + mouseY < 1) {
                window.isMaximized = true;
                window.showMaximized();
            }
        }

        onMouseXChanged: {
            if (window.isMaximized) {
                window.isMaximized = false;
                window.showNormal();
            }

            var dx = mouseX - previousX
            window.setX(window.x + dx)
        }

        onMouseYChanged: {
            if (window.isMaximized) {
                window.isMaximized = false;
                window.showNormal();
            }

            var dy = mouseY - previousY
            window.setY(window.y + dy)
        }
    }
}
