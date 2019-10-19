import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.2
import "BasicComponents"
import "Dialogs"

Window {
    id: mainWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    width: 1300
    height: 768
    property int previousX
    property int previousY
    property bool isMaximized: false
    property bool isClosing: false
    property int tabsRemaining: -1
    readonly property int margin: 5

    color: "#454545"

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

    Connections {
        target: Anthem
        onSaveDialogRequest: {
            saveFileDialog.open();
        }
    }

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

    FileDialog {
        id: saveFileDialog
        title: "Save as"
        selectExisting: false
        folder: shortcuts.home
        nameFilters: ["Anthem project files (*.anthem)"]
        onAccepted: {
            Anthem.saveActiveProjectAs(saveFileDialog.fileUrl.toString().substring(8));
            Anthem.notifySaveCompleted();
            if (isClosing) {
                closeWithSavePrompt();
            }
        }
        onRejected: {
            Anthem.notifySaveCancelled();
            isClosing = false;
            tabsRemaining = -1;
        }
    }

    ResizeHandles {
        anchors.fill: parent
        mainWindow: mainWindow
    }

    Shortcut {
        sequence: "Ctrl+Z"
        onActivated: Anthem.undo()
    }

    Shortcut {
        sequence: "Ctrl+Shift+Z"
        onActivated: Anthem.redo()
    }

    Image {
        id: asdf
        source: "Images/pretty.jpg"
        anchors.fill: parent
    }
    FastBlur {
        id: blurredbg
        visible: true
        anchors.fill: asdf
        source: asdf
        radius: 128
    }

    Item {
        id: header
        width: parent.width
        height: 30

        anchors.top: parent.top

        Item {
            id: headerControlsContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: margin
            anchors.leftMargin: margin
            anchors.rightMargin: margin
            height: 20

            MoveHandle {
                window: mainWindow
                anchors.fill: parent
            }

            TabGroup {
                id: tabGroup
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                // Width is managed internally by TabGroup

                onLastTabClosed: Qt.quit()
            }

            WindowControls {
                id: windowControlButtons
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                onMinimizePressed: {
                    mainWindow.showMinimized();
                }

                onMaximizePressed: {
                    if (mainWindow.isMaximized)
                        mainWindow.showNormal();
                    else
                        mainWindow.showMaximized();

                    mainWindow.isMaximized = !mainWindow.isMaximized;
                }

                onClosePressed: {
                    mainWindow.closeWithSavePrompt();
                }
            }
        }
    }

    Item {
        id: mainContentContainer

        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footerContainer.top

        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.bottomMargin: 5

        ControlsPanel {
            id: controlsPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }

        MainStack {
            anchors.top: controlsPanel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.topMargin: 4
        }
    }

    Item {
        id: footerContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 30
    }
}
