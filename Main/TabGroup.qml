import QtQuick 2.13
import "BasicComponents"

Item {
    id: tabGroup

    property Component tabComponent
    property int selectedTabIndex: 0
    property int tabCount: 1
    property int tabWidth: 124
    width: tabCount * (tabWidth + 3)

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
        if (tabComponent === null || tabComponent === undefined)
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
        tabGroup.children[index].title = name;
    }

    function selectTab(index) {
        console.log('select', index);
        tabGroup.children[selectedTabIndex].isSelected = false;
        tabGroup.children[index].isSelected = true;
        selectedTabIndex = index;
    }

    function doOnTabPressed(index) {
        console.log('do on tab pressed', index);
        selectTab(index);
        Anthem.switchActiveProject(index);
    }

    function removeTab(index) {
        for (let i = index; i < tabCount; i++) {
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

        tabGroup.children[index].destroy();
        tabCount--;
    }

    function doOnTabClosePressed(index) {
        removeTab(index);
        Anthem.closeProject(index);
        Anthem.switchActiveProject(selectedTabIndex);
    }

    Connections {
        target: Anthem
        onTabAdd: {
            addTab(name);
        }
        onTabRename: {
            renameTab(index, tab);
        }
        onTabSelect: {
            selectTab(index);
        }
        onTabRemove: {
            removeTab(index);
        }
    }
}
