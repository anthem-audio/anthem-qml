import QtQuick 2.0
import io.github.anthem.utilities.mousehelper 1.0

MouseArea {
    id: mouseArea
    hoverEnabled: true

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

    onPressed: {
        mouseHelper.setCursorToBlank();

        let mousePos = mouseHelper.getCursorPosition();
        props.currentSnapX = mousePos.x;
        props.currentSnapY = mousePos.y;

        isDragActive = true;
        dragStart();
    }

    onReleased: {
        mouseHelper.setCursorToArrow();

        isDragActive = false;
        dragEnd();
    }

    onPositionChanged: {
        if (!isDragActive)
            return;

        let mousePos = mouseHelper.getCursorPosition();
        let deltaX = mousePos.x - props.currentSnapX;
        let deltaY = props.currentSnapY - mousePos.y;

        if (deltaX === 0 && deltaY === 0)
            return;

        drag(deltaX, deltaY);
        mouseHelper.setCursorPosition(props.currentSnapX, props.currentSnapY);
    }
}
