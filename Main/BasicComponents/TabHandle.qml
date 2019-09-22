import QtQuick 2.0

Button {
    id: tabHandle
    property string title: "New project"
    property bool isSelected
    property int index

    signal btnClosePressed(int index)
    signal selected(int index)

    textContent: title
    textFloat: "left"

    isHighlighted: isSelected

    onPress: selected(index)

    Button {
        height: parent.height
        width: parent.height
        anchors.right: parent.right
        anchors.top: parent.top

        showBorder: false
        showBackground: false

        imageSource: "Images/Close.svg"
        imageWidth: 8
        imageHeight: 8

        isHighlighted: isSelected

        onPress: btnClosePressed(tabHandle.index)
    }
}
