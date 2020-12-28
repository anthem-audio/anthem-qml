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

import Anthem 1.0

Item {
    id: projectSwitcher

    property Project selectedProject

    function add(key) {
        const component = Qt.createComponent("Project.qml");
        const instance = component.createObject(projectSwitcher, { key });
        return instance;
    }

    function remove(key) {
        for (let i = 0; i < children.length; i++) {
            const child = children[i];
            if (child.key === key) {
                child.destroy();
                break;
            }
        }
    }

    Component.onCompleted: {
        const projectKey = Anthem.getActiveProjectKey();
        globalStore.selectedTabKey = projectKey;
        selectedProject = add(projectKey);
    }

    Connections {
        target: Anthem
        function onTabAdd(name, key) {
            // Adding always causes a tab change
            selectedProject = add(key);
        }
        function onTabSelect(index, key) {
            globalStore.selectedTabKey = key;
        }
        function onTabRemove(index, key) {
            remove(key);
        }
    }

    Connections {
        target: globalStore
        function onSelectedTabKeyChanged() {
            const key = globalStore.selectedTabKey;
            for (let i = 0; i < children.length; i++) {
                const child = children[i];
                if (child.key === key) {
                    selectedProject = child;
                    break;
                }
            }
        }
    }

    ProjectShortcuts {
        id: shortcuts
        onUndo: selectedProject.undo()
        onRedo: selectedProject.redo()
    }
}
