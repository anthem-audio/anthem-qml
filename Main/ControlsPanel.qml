import QtQuick 2.0
import "BasicComponents"

Panel {
    height: 44
    Item {
        id: controlPanelSpacer
        anchors.fill: parent
        anchors.margins: 6

        // Float left

        Button {
            id: btnLogo // No idea what this button does. Possibly opens up a dialog with info about the software? Or a welcome dialog or something.
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.height // makes it square :)

            imageSource: "Images/Logo.svg"
            imageWidth: 14
            imageHeight: 12
        }

        Button {
            id: btnFile
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnLogo.right
            anchors.leftMargin: 2
            width: parent.height

            textContent: "File"

            hasMenuIndicator: true
        }



        Button {
            id: btnSave
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnFile.right
            anchors.leftMargin: 20
            width: parent.height

            imageSource: "Images/Save.svg"
            imageWidth: 16
            imageHeight: 16
        }

        Button {
            id: btnUndo
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnSave.right
            anchors.leftMargin: 2
            width: parent.height

            imageSource: "Images/Undo.svg"
            imageWidth: 15
            imageHeight: 15
        }

        Button {
            id: btnRedo
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: btnUndo.right
            anchors.leftMargin: 2
            width: parent.height

            imageSource: "Images/Redo.svg"
            imageWidth: 15
            imageHeight: 15
        }



        // Float middle
        Item {
            /*
              This item is used to center a group of contorls in its parent.

              In a perfect world, I would have the item adapt to the width of its
                content and then center itself in the parent, but I don't know how
                to do the former and I'm on a plane right now so I'm going to have
                to settle for hard-coding the width.

              -- Joshua Wade, Jun 11, 2019
              */

            id: centerPositioner
            width: 498
            height: parent.height
            anchors.centerIn: parent

            Button {
                id: btnMetronomeToggle
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                width: parent.height

                isToggleButton: true
            }
        }

        // Float right

        Button {
            id: btnIGenuinelyDontKnow
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: parent.height
        }
    }
}
