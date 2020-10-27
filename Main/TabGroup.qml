/*
    Copyright (C) 2019 - 2020 Joshua Wade

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
import "BasicComponents"
import "Global"
import "Dialogs"

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
        { text: 'New project 1' },
    ]

    readonly property real tabWidth: 126
    width: tabWidth * rowModel.length

    QtObject {
        id: tabGroupProps
        property bool isSaveInProgress: false
        property int  currentSavingTabIndex: -1
    }

    onRowModelChanged: {
        globalStore.tabCount = rowModel.length;
    }

    signal lastTabClosed()

    SaveDiscardCancelDialog {
        id: saveConfirmDialog
        title: "Unsaved changes"
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: doOnTabClosePressed(globalStore.selectedTabIndex)
    }

    property real newProjectCounter: 2;

    function addTab(tabName) {
        rowModel = [...rowModel, { text: `New project ${newProjectCounter}` }];
        newProjectCounter++;
    }

    function renameTab(index, name) {
        const newRowModel = [...rowModel];
        newRowModel[index].text = name;
        rowModel = newRowModel;
    }

    function doOnTabPressed(index) {
        Anthem.switchActiveProject(index);
        globalStore.selectedTabIndex = index;
    }

    function removeTab(index) {
        const tabCount = globalStore.tabCount;

        let isLastTab = false;

        if (globalStore.selectedTabIndex === tabCount - 1) {
            isLastTab = true;
        }

        if (globalStore.selectedTabIndex === index) {
            if (isLastTab)
                globalStore.selectedTabIndex--;
            else
                globalStore.selectedTabIndex++;
        }

        if (index < globalStore.selectedTabIndex)
            globalStore.selectedTabIndex--;

        rowModel = rowModel.filter((_, i) => i !== index);
    }

    function doOnCloseConfirmation(index) {
        if (index === undefined) {
            index = tabGroupProps.currentSavingTabIndex;
        }

        if (globalStore.tabCount <= 1) {
            Anthem.closeProject(0);
            lastTabClosed();
        }
        else {
            Anthem.closeProject(index);
            Anthem.switchActiveProject(globalStore.selectedTabIndex);
        }
    }

    function doOnTabClosePressed(index) {
        if (Anthem.projectHasUnsavedChanges(index)) {
            tabGroupProps.currentSavingTabIndex = index;
            let projectName = tabGroup.children[index].title;
            saveConfirmDialog.message =
                `${projectName} ${qsTr('has unsaved changes. Would you like to save before closing?')}`;
            saveConfirmDialog.show();
        }
        else {
            doOnCloseConfirmation(index);
        }
    }

    Connections {
        target: saveConfirmDialog
        function onSavePressed() {
            if (Anthem.isProjectSaved(tabGroupProps.currentSavingTabIndex)) {
                saveLoadHandler.saveActiveProject();
                doOnCloseConfirmation();
            }
            else {
                tabGroupProps.isSaveInProgress = true;
                saveLoadHandler.openSaveDialog();
            }
        }
        function onDiscardPressed() {
            doOnCloseConfirmation();
        }
    }

    Connections {
        target: Anthem
        function onTabAdd(name) {
            addTab(name);
            commands.histories.push([]);
            commands.historyPointers.push(-1);
        }
        function onTabRename(index, name) {
            renameTab(index, name);
        }
        function onTabSelect(index) {
            globalStore.selectedTabIndex = index;
        }
        function onTabRemove(index) {
            removeTab(index);
            commands.histories.splice(index, 1);
            commands.historyPointers.splice(index, 1);
        }
    }

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

                property bool hovered: tabMouseArea.hovered || closeButton.hovered
                property color tabColor: index === globalStore.selectedTabIndex || hovered ? colors.white_12 : colors.white_7

                AsymRoundRect {
                    anchors {
                        fill: parent
                        rightMargin: 1
                        bottomMargin: 1
                    }

                    startRadius: 2
                    endRadius: index === globalStore.selectedTabIndex ? 0 : 1
                    direction: AsymRoundRect.Direction.Vertical

                    color: tabContainer.tabColor

                    Text {
                        text: modelData.text
                        anchors {
                            verticalCenter: closeButton.verticalCenter
                            verticalCenterOffset: -1
                            left: parent.left
                            leftMargin: 13
                            right: closeButton.left
                            rightMargin: 4
                        }
                        font.family: Fonts.mainRegular.name
                        font.pixelSize: 13
                        color: colors.white_70
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: tabMouseArea
                        property bool hovered: false
                        anchors.fill: parent
                        onClicked: {
                            globalStore.selectedTabIndex = index;
                            doOnTabPressed(index);
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

                        onClicked: {
                            doOnTabClosePressed(index);
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
                    visible: index === globalStore.selectedTabIndex
                }
            }
        }
    }
}
