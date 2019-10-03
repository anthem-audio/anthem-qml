import QtQuick 2.13
import "BasicComponents"

Item {
    id: tabGroup

    property Component tabComponent
    property int selectedTabIndex: 0
    property int tabCount: 1
    property int tabWidth: 124
    width: tabCount * (tabWidth + 3)

    signal lastTabClosed()

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
        tabGroup.children[selectedTabIndex].isSelected = false;
        tabGroup.children[index].isSelected = true;
        selectedTabIndex = index;
    }

    function doOnTabPressed(index) {
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
        if (tabCount <= 1) {
            // TODO: prompt for save before closing
            tabGroup.children[0].destroy();
            Anthem.closeProject(index);
            lastTabClosed();
        }
        else {
            removeTab(index);
            Anthem.closeProject(index);
            Anthem.switchActiveProject(selectedTabIndex);
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
    }
}
