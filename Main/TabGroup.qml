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
        anchors.left: parent.left
        anchors.top: parent.top
        width: tabWidth
        isSelected: true
        index: 0

        onSelected: selectTab(index)
        onBtnClosePressed: removeTab(index)
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
            tab.selected.connect(selectTab);
            tab.btnClosePressed.connect(removeTab);
            selectTab(tabCount);
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
        tabGroup.children[selectedTabIndex].isSelected = false;
        tabGroup.children[index].isSelected = true;
        selectedTabIndex = index;
        // TODO: tell the presenter to switch the active tab
    }

    function removeTab(index) {
        if (index === 0)
            tabGroup.children[index].anchors.left = undefined;
        else if (index !== tabCount - 1)
            tabGroup.children[index].anchors.left = undefined;

        for (let i = index; i < tabCount; i++) {
            tabGroup.children[i].index--;
            tabGroup.children[i].x -= (tabWidth + 3);
        }

        let isLastTab = false;

        if (selectedTabIndex === tabCount - 1) {
            selectedTabIndex--;
            isLastTab = true;
        }

        if (selectedTabIndex === index) {
            if (isLastTab)
                selectTab(selectedTabIndex - 1);
            else
                selectTab(selectedTabIndex + 1);
        }

        tabGroup.children[index].destroy();
        tabCount--;

        // TODO: Tell the presenter to clean up the closed tab
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
