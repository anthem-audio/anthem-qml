import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.2
import "BasicComponents"
import "Dialogs"
import "Global"

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

    InformationDialog {
        id: infoDialog
    }

    Connections {
        target: Anthem
        onSaveDialogRequest: {
            saveFileDialog.open();
        }
        onInformationDialogRequest: {
            infoDialog.title = title;
            infoDialog.message = notification;
            infoDialog.show();
        }
        onStatusMessageRequest: {
            statusText.text = message;
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
        anchors.bottomMargin: 10

        ControlsPanel {
            id: controlsPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }

        MainStack {
            id: mainStack
            anchors.top: controlsPanel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 4
            showControllerRack: btnShowControllerRack.pressed
            showExplorer: explorerTabs.selectedIndex > -1
            showEditors: editorPanelTabs.selectedIndex > -1
        }
    }

    Item {
        id: footerContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        height: 15
        width: 65

        ButtonGroup {
            id: explorerTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            showBackground: false
            defaultWidth: 25
            defaultImageWidth: 15
            defaultHeight: 15
            defaultLeftMargin: 20
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 0
            allowDeselection: true

            model: [
                {
                    leftMargin: 15,
                    imagePath: "Images/File.svg",
                    hoverMessage: "File explorer"
                },
                {
                    imagePath: "Images/Document.svg",
                    imageWidth: 11,
                    hoverMessage: "Project explorer"
                }
            ]
        }

        Rectangle {
            id: spacer1
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: explorerTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        ButtonGroup {
            id: layoutTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: spacer1.right
            anchors.leftMargin: 5
            showBackground: false
            defaultHeight: 15
            defaultLeftMargin: 15
            buttonAutoWidth: true
            defaultInnerMargin: 0
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 0

            model: [
                {
                    textContent: "ARRANGE",
                    hoverMessage: "Arrangement layout"
                },
                {
                    textContent: "MIX",
                    hoverMessage: "Mixing layout"
                },
                {
                    textContent: "EDIT",
                    hoverMessage: "Editor layout"
                }
            ]
        }

        Rectangle {
            id: spacer2
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: layoutTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        ButtonGroup {
            id: editorPanelTabs
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: spacer2.right
            showBackground: false
            defaultWidth: 25
            defaultImageWidth: 15
            defaultHeight: 15
            defaultLeftMargin: 10
            defaultTopMargin: 0
            width: 140
            managementType: ButtonGroup.ManagementType.Selector
            selectedIndex: 3
            allowDeselection: true

            model: [
                {
                    imagePath: "Images/Piano Roll.svg",
                    hoverMessage: "Piano roll"
                },
                {
                    imagePath: "Images/Automation.svg",
                    hoverMessage: "Automation editor"
                },
                {
                    imagePath: "Images/Plugin.svg",
                    hoverMessage: "Plugin rack"
                },
                {
                    imagePath: "Images/Mixer.svg",
                    hoverMessage: "Mixer"
                }
            ]
        }

        Rectangle {
            id: spacer3
            width: 2
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: editorPanelTabs.right
            anchors.leftMargin: 20
            color: Qt.rgba(1, 1, 1, 0.11)
        }

        Text {
            id: statusText
            anchors.left: spacer3.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            text: ""
            font.family: Fonts.notoSansRegular.name
            font.pixelSize: 11
            color: Qt.rgba(1, 1, 1, 0.6)
        }

        Button {
            id: btnShowControllerRack
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 15
            width: 15
            imageSource: "Images/Controllers.svg"
            imageWidth: 15
            imageHeight: 15
            showBorder: false
            showBackground: false
            isToggleButton: true
            pressed: true
            hoverMessage: pressed ? "Hide controller rack" : "Show controller rack"
        }
    }
}
