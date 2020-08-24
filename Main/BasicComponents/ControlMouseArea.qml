/*
    Copyright (C) 2019, 2020 Joshua Wade

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

/*
    When a drag is completed in a ControlMouseArea, the mouse will
    snap back to the position it was in when the drag started.

    This is fine, except it doesn't cause the enter() signal to fire.

    Which *would* be fine, except that the knob (and maybe some
    others?) need onExited to revert from a hover state, but after
    the mouse is teleported back to the mouse area, onExited doesn't
    fire when the mouse is subsequently moved out of the mouse area.

    There's a workaround:
    https://stackoverflow.com/q/63532184/8166701

    I tried implementing it, but it just uncovers another issue:
    If you move the mouse too soon after clicking, the hover state
    will be incorrect when the mouse is released.

    I'd rather it be consistently incorrect than inconsistently
    correct.
*/

import QtQuick 2.15
import QtQuick.Window 2.15
import io.github.anthem.utilities.mousehelper 1.0

MouseArea {
    id: mouseArea
    hoverEnabled: true

    MouseHelper {
        id: mouseHelper
    }

    property bool isDragActive: false
    enabled: !isDragActive

    QtObject {
        id: state
        property real snapX: Screen.width * 0.5
        property real snapY: Screen.height * 0.5
        property real startX
        property real startY
    }

    signal dragStart()
    signal drag(real deltaX, real deltaY)
    signal dragEnd()

    onPressed: {
        mouseHelper.setCursorToBlank();

        let mousePos = mouseHelper.getCursorPosition();
        state.startX = mousePos.x;
        state.startY = mousePos.y;

        isDragActive = true;
        mouseHelper.setCursorPosition(state.snapX, state.snapY);
        dragStart();
    }

    onReleased: {
        mouseHelper.setCursorPosition(state.startX, state.startY);
        mouseHelper.clearOverride();

        isDragActive = false;

        dragEnd();
    }

    onPositionChanged: {
        if (!isDragActive)
            return;

        let mousePos = mouseHelper.getCursorPosition();
        let deltaX = mousePos.x - state.snapX;
        let deltaY = state.snapY - mousePos.y;

        if (deltaX === 0 && deltaY === 0)
            return;

        drag(deltaX, deltaY);
        mouseHelper.setCursorPosition(state.snapX, state.snapY);
    }
}
