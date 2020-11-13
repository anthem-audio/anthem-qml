# Menu

## Table of contents
- [Menu](#menu)
  - [Table of contents](#table-of-contents)
  - [Properties](#properties)
    - [`menuX` and `menuY`](#menux-and-menuy)
    - [`minWidth`](#minwidth)
    - [`maxWidth`](#maxwidth)
    - [`maxHeight`](#maxheight)
    - [`menuItems`](#menuitems)
  - [Methods](#methods)
    - [`open()`](#open)
  - [Example](#example)

The `Menu` component is a fully-custom, multi-purpose system for application and context menus.

## Properties

----

### `menuX` and `menuY`

Default: `0`

These properties define the position of the menu relative to the parent.

```qml
Rectangle {
    color: "red"
    width: 100
    height: 100
    Menu {
        id: menu
        // When menu.open() is called, the top-left
        // of the menu will be in the middle of the
        // parent.
        menuX: parent.width * 0.5
        menuY: parent.width * 0.5
    }
}
```

----

### `minWidth`

Default: `undefined`

Defines the minimum column width. If left unset, there will be no minimum.

----

### `maxWidth`

Default: `undefined`

Defines the maximum column width. If left unset, there will be no maximum.

----

### `maxHeight`

Default: `undefined`

Defines the maximum height for a column. If a column exceeds this height, the extra will be wrapped into a new column. 

----

### `menuItems`

Defines the menu content.

`menuItems` should be a list of Javascript objects in the following format:

```qml
Menu {
    //...
    MenuItems: [
        {
            // The underscore here will underiline 
            // the 'N' and turn it into a shortcut.
            // When the menu is opened, pressing 'n'
            // will activate this menu option.
            text: 'N_ew project',

            // Defines text to be shown as the
            // shortcut for this menu option. 
            // Defining this does not actually
            // create a working shortcut - it's
            // just visual.
            // 
            // This property is optional.
            shortcut: 'Ctrl+N', 

            // Text to be displayed on the bottom
            // of the screen in the info section
            // when the user hovers over this menu
            // option.
            // 
            // This property is optional.
            hoverText: 'Start a new project',

            // If set to true, this menu item will
            // display in a disabled state. Disabled
            // menu items cannot be interacted with.
            // 
            // This property is optional. If unset,
            // it will default to false.
            disabled: true,

            // Function to be called when this
            // menu item is activated.
            onTriggered: () => {
                Anthem.newProject();
            }
        },
        // More menu items here...
    ]
}
```

Additionally, there are some special-case menu properties:

```qml
Menu {
    //...
    MenuItems: [
        {
            //...
        },
        {
            // Defines a menu separator
            separator: true
        },
        {
            text: 'Submenu test',
            // Defines a submenu for this menu item. If
            // unset, there will be no submenu.
            submenu: [
                {
                    text: 'Item 1'
                },
                {
                    text: 'Item 2'
                },
                {
                    text: 'Item 3'
                }
            ]
        },
        {
            // Defines a column break. Menu items after
            // this will be placed in a new column.
            newColumn: true
        },
        {
            text: 'New column item 1'
        },
        {
            text: 'New column item 2'
        },
        //...
    ]
}
```

## Methods

----

### `open()`

Opens this menu.

## Example

---

```qml
 Button {
    id: btnFile
    width: 25
    height: 25

    textContent: "File"

    hasMenuIndicator: true

    onPress: fileMenu.open()

    Shortcut {
        sequence: "alt+f"
        onActivated: fileMenu.open()
    }

    Menu {
        id: fileMenu
        menuX: 0
        menuY: parent.height

        menuItems: [
            {
                text: 'N_ew project',
                shortcut: 'Ctrl+N',
                hoverText: 'Start a new project',
                onTriggered: () => {
                    Anthem.newProject();
                }
            },
            {
                text: 'O_pen...',
                shortcut: 'Ctrl+O',
                hoverText: 'Open an existing project',
                onTriggered: () => {
                    loadFileDialog.open();
                }
            },
            {
                separator: true
            },
            {
                text: 'S_ave',
                shortcut: 'Ctrl+S',
                hoverText: 'Save this project',
                onTriggered: () => {
                    save();
                }
            },
            {
                text: 'Save a_s...',
                hoverText: 'Save this project to a different file',
                onTriggered: () => {
                    saveFileDialog.open();
                }
            },
            {
                separator: true
            },
            {
                text: 'Ex_it',
                hoverText: 'Quit Anthem',
                onTriggered: () => {
                    closeRequested();
                }
            },
            {
                separator: true
            },
            {
                text: 'Submenu test',
                submenu: [
                    {
                        text: 'Item 1'
                    },
                    {
                        text: 'Disabled item 2',
                        disabled: true
                    },
                    {
                        newColumn: true
                    },
                    {
                        text: 'New column item 1'
                    },
                    {
                        text: 'New column item 2'
                    },
                    {
                        text: 'New column item 3'
                    },
                    {
                        text: 'New column item 4',
                        submenu: [
                            {
                                text: 'Sub-submenu item 1'
                            },
                            {
                                text: 'Sub-submenu item 2'
                            },
                            {
                                text: 'Sub-submenu item 3'
                            }
                        ]
                    },
                    {
                        text: 'New column item 5'
                    },
                ]
            }
        ]
    }
```