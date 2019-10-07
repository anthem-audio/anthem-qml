import QtQuick 2.13
import QtQuick.Window 2.13
import QtQuick.Shapes 1.13
import QtGraphicalEffects 1.13
import "BasicComponents"

Window {
    id: mainWindow
    flags: Qt.Window | Qt.FramelessWindowHint
    visible: true
    width: 1300
    height: 768
    property int previousX
    property int previousY
    property bool isMaximized: false
    readonly property int margin: 5

    color: "#454545"

    function closeWithSavePrompt() {
        // TODO: if project has unsaved changes, prompt to save
        close();
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
                mainWindow: mainWindow
                anchors.fill: parent
            }

            TabGroup {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                // Width is managed internally by TabGroup

                onLastTabClosed: mainWindow.closeWithSavePrompt()
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
