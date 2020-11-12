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

import QtQuick 2.15

Item {
    id: projectSwitcher
    function add() {
        const component = Qt.createComponent("Project.qml");
        const instance = component.createObject(projectSwitcher, { visible: false });
    }

    function select(index) {
        for (let i = 0; i < children.length; i++) {
            children[i].visible = index === i;
        }
    }

    function remove(index) {
        children[index].destroy();
    }

    Component.onCompleted: {
        add()
        select(0)
    }

    Connections {
        target: Anthem
        function onTabAdd() {
            add();
        }
        function onTabSelect(index) {
            select(index);
        }
        function onTabRemove(index) {
            remove(index);
        }
    }
}
