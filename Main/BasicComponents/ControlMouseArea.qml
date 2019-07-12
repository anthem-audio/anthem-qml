import QtQuick 2.0
import io.github.anthem.utilities.mousehelper 1.0

Item {
    MouseHelper {
        id: mouseHelper
    }

    property bool isDragActive: false

    QtObject {
        id: props
        property real currentSnapX
        property real currentSnapY
    }

    signal dragStart()
    signal drag(real deltaX, real deltaY)
    signal dragEnd()

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onPressed: {
            mouseHelper.setCursorToBlank();

            let mousePos = mouseHelper.getCursorPosition();
            props.currentSnapX = mousePos.x;
            props.currentSnapY = mousePos.y;

            parent.isDragActive = true;
            parent.dragStart();
        }

        onReleased: {
            mouseHelper.setCursorToArrow();

            parent.isDragActive = false;
            parent.dragEnd();
        }

        onPositionChanged: {
            if (!parent.isDragActive)
                return;

            let mousePos = mouseHelper.getCursorPosition();
            let deltaX = mousePos.x - props.currentSnapX;
            let deltaY = props.currentSnapY - mousePos.y;

            if (deltaX === 0 && deltaY === 0)
                return;

            parent.drag(deltaX, deltaY);
            mouseHelper.setCursorPosition(props.currentSnapX, props.currentSnapY);
        }
    }
}
