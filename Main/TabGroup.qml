import QtQuick 2.13
import "BasicComponents"

Item {
    width: 124

    Button {
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        width: 124
        textContent: "Project 1"
        textFloat: "left"

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
        }
    }
}
