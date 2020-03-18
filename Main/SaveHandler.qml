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
import QtQuick.Dialogs 1.2
import "Dialogs"

Item {
    signal saveCompleted();
    signal saveCancelled();

    property bool isClosing: false
    property int tabsRemaining: -1

    function closeWithSavePrompt() {
        let checkForUnsaved = () => {
            if (!isClosing) {
                isClosing = true;
                tabsRemaining = tabGroup.children.length;
            }
            if (Anthem.getNumOpenProjects() <= 0) {
                Qt.quit();
            }
            else if (Anthem.projectHasUnsavedChanges(0)) {
                Anthem.switchActiveProject(0);
                tabGroup.selectTab(0);

                let projectName = tabGroup.children[0].title;
                saveConfirmDialog.message = `${projectName} has unsaved changes. Would you like to save before closing?`;
                saveConfirmDialog.show();

                return;
            }
            else {
                closeWithSavePrompt();
                return;
            }
        }

        if (isClosing) {
            if (tabGroup.tabCount <= 1) {
                Qt.quit();
            }

            Anthem.closeProject(0);
            tabGroup.getTabAtIndex(0).Component.destruction.connect(checkForUnsaved);
            tabGroup.removeTab(0);
            tabsRemaining = tabsRemaining - 1;
        }
        else {
            checkForUnsaved();
        }
    }

    function save() {
        if (Anthem.isProjectSaved(Anthem.activeProjectIndex)) {
            Anthem.saveActiveProject();
            if (isClosing) {
                closeWithSavePrompt();
            }
        }
        else {
            saveFileDialog.open();
        }
    }

    function openSaveDialog() {
        saveFileDialog.open();
    }

    FileDialog {
        id: saveFileDialog
        title: "Save as"
        selectExisting: false
        folder: shortcuts.home
        nameFilters: ["Anthem project files (*.anthem)"]
        onAccepted: {
            Anthem.saveActiveProjectAs(saveFileDialog.fileUrl.toString().substring(8));
            saveCompleted();
            if (isClosing) {
                closeWithSavePrompt();
            }
        }
        onRejected: {
            saveCancelled();
            isClosing = false;
            tabsRemaining = -1;
        }
    }

    FileDialog {
        id: loadFileDialog
        title: "Select a project"
        selectExisting: true
        folder: shortcuts.home
        nameFilters: ["Anthem project files (*.anthem)"]
        onAccepted: {
            Anthem.loadProject(loadFileDialog.fileUrl.toString().substring(8));
        }
    }

    SaveDiscardCancelDialog {
        id: saveConfirmDialog
        title: "Unsaved changes"
        onCancelPressed: {
            isClosing = false;
            tabsRemaining = -1;
        }
        onDiscardPressed: {
            closeWithSavePrompt();
        }
        onSavePressed: {
            save();
        }
    }
}
