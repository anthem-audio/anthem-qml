/*
    Copyright (C) 2020 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

import QtQuick 2.14

Item {
    id: container
    property var _idCounter: 0
    property int openItemCount: 0

    signal tooltipOpened(int tooltipId)
    signal tooltipClosed(int tooltipId)

    function open(component, x, y) {
        if (component.status === Component.Ready) {
            let tooltip =
                component.createObject(
                    container, { x, y, id: _idCounter }
                );

            _idCounter++;
            openItemCount++;

            tooltipOpened(_idCounter - 1);
            return _idCounter - 1;
        }
        else if (component.status === Component.Error) {
            console.error(
                "Error loading component:",
                tooltipComponent.errorString()
            );
        }
        else {
            console.error("tooltipComponent.status is not either \"ready\" or \"error\". This may mean the component hasn't loaded yet. This shouldn't be possible.");
        }
        return -1;
    }

    function close(id) {
        for (let i = 1; i < children.length; i++) {
            if (children[i].id === id) {
                tooltipClosed(id);
                children[i].destroy();
                openItemCount--;

                return id;
            }
        }

        return -1;
    }

    function closeAll() {
        for (let i = 1; i < children.length; i++) {
            tooltipClosed(children[i].id);
            children[i].destroy();
        }

        openItemCount = 0;
    }

    function closeLast() {
        tooltipClosed(children[children.length - 1].id);
        children[children.length - 1].destroy();
        openItemCount--;
    }

    MouseArea {
        anchors.fill: openItemCount > 0 ? parent : undefined
        width: openItemCount < 1 ? 0 : undefined
        height: openItemCount < 1 ? 0 : undefined

        onPressed: {
            closeLast();
        }
    }
}
