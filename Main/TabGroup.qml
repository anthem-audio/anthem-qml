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

import QtQuick 2.13
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
    property int selectedTabIndex: 0
    property int tabCount: 1
    property int tabWidth: 124

    QtObject {
        id: tabGroupProps
        property bool isSaveInProgress: false
        property int  currentSavingTabIndex: -1
    }

    width: tabCount * (tabWidth + 3)

    signal lastTabClosed()

    SaveDiscardCancelDialog {
        id: saveConfirmDialog
        title: "Unsaved changes"
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
                x: tabCount * (tabWidth + 3),
                y: tabGroup.y,
                width: 124,
                title: tabName,
                index: tabCount,
                isSelected: false,
            }

            let tab = tabComponent.createObject(tabGroup, options);
            tab.selected.connect(doOnTabPressed);
            tab.btnClosePressed.connect(doOnTabClosePressed);
            tabCount++;
        }
        else if (tabComponent.status === Component.Error) {
            console.error("Error loading component:", tabComponent.errorString());
        }
        else {
            console.error("tabComponent.status is not either \"ready\" or \"error\". This may mean the component hasn't loaded yet. This shouldn't be possible.");
        }
    }

    function renameTab(index, name) {
        let offset = children.length - tabCount;
        tabGroup.children[index + offset].title = name;
    }

    function selectTab(index) {
        let offset = children.length - tabCount;
        tabGroup.children[selectedTabIndex + offset].isSelected = false;
        tabGroup.children[index + offset].isSelected = true;
        selectedTabIndex = index;
    }

    function doOnTabPressed(index) {
        let offset = children.length - tabCount;
        selectTab(index + offset);
        Anthem.switchActiveProject(index + offset);
    }

    function removeTab(index) {
        let offset = children.length - tabCount;

        for (let i = index + offset; i < tabCount + offset; i++) {
            tabGroup.children[i].index--;
            tabGroup.children[i].x -= (tabWidth + 3);
        }

        let isLastTab = false;

        if (selectedTabIndex === tabCount - 1) {
            isLastTab = true;
        }

        if (selectedTabIndex === index) {
            if (isLastTab)
                selectTab(selectedTabIndex - 1);
            else
                selectTab(selectedTabIndex + 1);
        }

        if (index < selectedTabIndex)
            selectedTabIndex--;

        tabGroup.children[index + offset].destroy();
        tabCount--;
    }

    function getTabAtIndex(index) {
        let offset = children.length - tabCount;
        return children[index + offset]
    }

    function doOnCloseConfirmation(index) {
        if (index === undefined) {
            index = tabGroupProps.currentSavingTabIndex;
        }

        if (tabCount <= 1) {
            tabGroup.children[0].destroy();
            Anthem.closeProject(0);
            lastTabClosed();
        }
        else {
            removeTab(index);
            Anthem.closeProject(index);
            Anthem.switchActiveProject(selectedTabIndex);
        }
    }

    function doOnTabClosePressed(index) {
        if (Anthem.projectHasUnsavedChanges(index)) {
            console.log(`Checked index ${index}. Project did have unsaved changes.`);
            tabGroupProps.currentSavingTabIndex = index;
            let projectName = tabGroup.children[index].title;
            saveConfirmDialog.message = `${projectName} has unsaved changes. Would you like to save before closing?`;
            saveConfirmDialog.show();
        }
        else {
            doOnCloseConfirmation(index);
        }
    }

    Connections {
        target: saveConfirmDialog
        onSavePressed: {
            if (Anthem.isProjectSaved(tabGroupProps.currentSavingTabIndex)) {
                Anthem.saveActiveProject();
                doOnCloseConfirmation();
            }
            else {
                tabGroupProps.isSaveInProgress = true;
                Anthem.openSaveDialog();
            }
        }
        onDiscardPressed: {
            doOnCloseConfirmation();
        }
    }

    Connections {
        target: Anthem
        onTabAdd: {
            addTab(name);
        }
        onTabRename: {
            renameTab(index, name);
        }
        onTabSelect: {
            selectTab(index);
        }
        onTabRemove: {
            removeTab(index);
        }
        onSaveCompleted: {
            if (tabGroupProps.isSaveInProgress) {
                doOnCloseConfirmation();
            }
            tabGroupProps.isSaveInProgress = false;
            tabGroupProps.currentSavingTabIndex = -1;
        }
        onSaveCancelled: {
            tabGroupProps.isSaveInProgress = false;
            tabGroupProps.currentSavingTabIndex = -1;
        }
    }
}
