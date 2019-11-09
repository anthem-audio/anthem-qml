import QtQuick 2.13

ButtonGroup {
    id: windowButtonsContainer

    property bool disableMinimize: false
    property bool disableMaximize: false
    property bool disableClose:    false

    signal minimizePressed()
    signal maximizePressed()
    signal closePressed()

    defaultButtonWidth: 26
    defaultButtonHeight: 20
    defaultImageWidth: 8
    defaultImageHeight: 8

    fixedWidth: false

    model: ListModel {
        // https://stackoverflow.com/a/33161093/8166701
        property bool completed: false
        Component.onCompleted: {
            model.setProperty(0, "isDisabled", disableMinimize);
            model.setProperty(1, "isDisabled", disableMaximize);
            model.setProperty(2, "isDisabled", disableClose);
            completed = true;
        }

        ListElement {
            imageSource: "Images/Minimize.svg"
            isDisabled: false
            hoverMessage: "Minimize"
            onPress: () => {
               windowButtonsContainer.minimizePressed();
            }
        }
        ListElement {
            imageSource: "Images/Maximize.svg"
            isDisabled: false
            hoverMessage: "Maximize"
            onPress: () => {
               windowButtonsContainer.maximizePressed();
            }
        }
        ListElement {
            imageSource: "Images/Close.svg"
            isDisabled: false
            hoverMessage: "Close"
            onPress: () => {
               windowButtonsContainer.closePressed();
            }
        }
    }

    onDisableMinimizeChanged: {
        model.setProperty(0, "isDisabled", disableMinimize);
    }
    onDisableMaximizeChanged: {
        model.setProperty(1, "isDisabled", disableMaximize);
    }
    onDisableCloseChanged: {
        model.setProperty(2, "isDisabled", disableClose);
    }
}
