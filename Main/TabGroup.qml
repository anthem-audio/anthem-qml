/*
    Copyright (C) 2019 Joshua Wade

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
import "BasicComponents"
import "Dialogs"

/*
  TabGroup is used to display the tabs at the
  top of the Anthem window.

  It's worth leaving a note about the offset
  variable in some of the functions below,
  calculated as
    let offset = children.length - tabCount;

  When a child item is removed programmatically,
  it does not immediately disappear. The Qt
  Quick engine takes care of removing it before
  the next frame. "Oh, I'll do it at some point
  before the next frame" gives no guarantee
  that the item will be gone by the time we are
  ready to manipulate the children again, and
  so this occasional discrepency must be
  accounted for.
*/

Item {
    id: tabGroup

    property Component tabComponent
    property int tabWidth: 124

    QtObject {
        id: tabGroupProps
        property bool isSaveInProgress: false
        property int  currentSavingTabIndex: -1
    }

    width: globalStore.tabCount * (tabWidth + 3)

    signal lastTabClosed()

    SaveDiscardCancelDialog {
        id: saveConfirmDialog
        title: "Unsaved changes"
    }

    Shortcut {
        sequence: "Ctrl+W"
        onActivated: doOnTabClosePressed(globalStore.selectedTabIndex)
    }

    TabHandle {
        height: parent.height
        x: parent.x
        y: parent.y
        width: tabWidth
        isSelected: true
        index: 0

        onSelected: doOnTabPressed(index)
        onBtnClosePressed: doOnTabClosePressed(index)
    }

    function addTab(tabName) {
        if (tabComponent === null)
            tabComponent = Qt.createComponent("BasicComponents/TabHandle.qml");

        if (tabComponent.status === Component.Ready) {
            let options = {
                height: tabGroup.height,
                x: globalStore.tabCount * (tabWidth + 3),
                y: tabGroup.y,
                width: 124,
                title: tabName,
                index: globalStore.tabCount,
                isSelected: false,
            }

            let tab = tabComponent.createObject(tabGroup, options);
            tab.selected.connect(doOnTabPressed);
            tab.btnClosePressed.connect(doOnTabClosePressed);
            globalStore.tabCount++;
        }
        else if (tabComponent.status === Component.Error) {
            console.error("Error loading component:", tabComponent.errorString());
        }
        else {
            console.error("tabComponent.status is not either \"ready\" or \"error\". This may mean the component hasn't loaded yet. This shouldn't be possible.");
        }
    }

    function renameTab(index, name) {
        let offset = children.length - globalStore.tabCount;
        tabGroup.children[index + offset].title = name;
    }

    function selectTab(index) {
        let offset = children.length - globalStore.tabCount;
        tabGroup.children[globalStore.selectedTabIndex + offset].isSelected = false;
        tabGroup.children[index + offset].isSelected = true;
        globalStore.selectedTabIndex = index;
    }

    function doOnTabPressed(index) {
        let offset = children.length - globalStore.tabCount;
        Anthem.switchActiveProject(index + offset);
        selectTab(index + offset);
    }

    function removeTab(index) {
        let offset = children.length - globalStore.tabCount;

        for (let i = index + offset; i < globalStore.tabCount + offset; i++) {
            tabGroup.children[i].index--;
            tabGroup.children[i].x -= (tabWidth + 3);
        }

        let isLastTab = false;

        if (globalStore.selectedTabIndex === globalStore.tabCount - 1) {
            isLastTab = true;
        }

        if (globalStore.selectedTabIndex === index) {
            if (isLastTab)
                selectTab(globalStore.selectedTabIndex - 1);
            else
                selectTab(globalStore.selectedTabIndex + 1);
        }

        if (index < globalStore.selectedTabIndex)
            globalStore.selectedTabIndex--;

        tabGroup.children[index + offset].destroy();
        globalStore.tabCount--;
    }

    function getTabAtIndex(index) {
        let offset = children.length - globalStore.tabCount;
        return children[index + offset]
    }

    function doOnCloseConfirmation(index) {
        if (index === undefined) {
            index = tabGroupProps.currentSavingTabIndex;
        }

        if (globalStore.tabCount <= 1) {
            tabGroup.children[0].destroy();
            Anthem.closeProject(0);
            lastTabClosed();
        }
        else {
//            removeTab(index);
            Anthem.closeProject(index);
            Anthem.switchActiveProject(globalStore.selectedTabIndex);
        }
    }

    function doOnTabClosePressed(index) {
        if (Anthem.projectHasUnsavedChanges(index)) {
            tabGroupProps.currentSavingTabIndex = index;
            let projectName = tabGroup.children[index].title;
            saveConfirmDialog.message = `${projectName} ${qsTr('has unsaved changes. Would you like to save before closing?')}`;
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

    // This code also handles discarding or adding to the list of undo/redo
    // stacks. The code for handling this should not be here but oh well
    Connections {
        target: Anthem
        function onTabAdd() {
            console.log('add');
            addTab(name);
            commands.histories.push([]);
            commands.historyPointers.push(-1);
        }
        function onTabRename() {
            renameTab(index, name);
        }
        function onTabSelect() {
            selectTab(index);
        }
        function onTabRemove() {
            removeTab(index);
            commands.histories.splice(index, 1);
            commands.historyPointers.splice(index, 1);
        }
    }
}
