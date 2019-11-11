/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.13
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
