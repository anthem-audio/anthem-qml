import QtQuick 2.15
import "BasicComponents"

Item {
    id: tabGroup
    /*
        Each item contains:
        {
            key: string;
            text: string;
        }
    */
    property var rowModel: [
        { key: '0', text: 'Project 1' },
        { key: '1', text: 'Project 2' },
        { key: '2', text: 'Project 3' },
        { key: '3', text: 'Project 4' },
        { key: '4', text: 'Project 5' },
    ]

    property real selected: 0

    readonly property real tabWidth: 126
    width: tabWidth * rowModel.length

    Row {
        id: thisIsARow
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        Repeater {
            model: tabGroup.rowModel
            Item {
                id: tabContainer
                width: tabWidth
                height: tabGroup.height
                Item {
                    clip: true
                    anchors {
                        fill: parent
                        rightMargin: 1
                        bottomMargin: 1
                    }
                    Rectangle {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }

                        height: index === selected ? parent.height + radius : parent.height
                        radius: 2

                        color: index === selected || hovered ? colors.white_12 : colors.white_7

                        property bool hovered: tabMouseArea.hovered || closeButton.hovered

                        Text {
                            text: modelData.text
                            anchors {
                                verticalCenter: closeButton.verticalCenter
                                verticalCenterOffset: -1
                                left: parent.left
                                leftMargin: 13
                            }
                            font.family: Fonts.main.name
                            font.pixelSize: 13
                            color: colors.white_70
                        }

                        MouseArea {
                            id: tabMouseArea
                            property bool hovered: false
                            anchors.fill: parent
                            onClicked: {
                                selected = index;
                            }
                            hoverEnabled: true
                            onEntered: {
                                hovered = true;
                            }
                            onExited: {
                                hovered = false;
                            }
                        }

                        Button {
                            id: closeButton
                            anchors {
                                top: parent.top
                                right: parent.right
                                topMargin: 8
                                rightMargin: 8
                            }
                            width: 20
                            height: 20

                            imageSource: "Images/icons/small/close.svg"
                            imageWidth: 8
                            imageHeight: 8

                            showBorder: false
                            showBackground: false
                        }
                    }
                }
                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 1
                    }
                    height: 1
                    color: colors.white_12
                    visible: index === selected
                }
            }
        }
    }

//    Rectangle {
//        anchors {
//            left: thisIsARow.right
//            top: parent.top
//            bottom: parent.bottom
//        }
//        width: 10
//        color: Qt.rgba(1, 1, 1, 0.2)
//        MouseArea {
//            anchors.fill: parent
//            onClicked: {
//                const oldRowModel = thisIsAnItem.rowModel;
//                thisIsAnItem.rowModel = [...oldRowModel, oldRowModel.length]
//            }
//        }
//    }
}
