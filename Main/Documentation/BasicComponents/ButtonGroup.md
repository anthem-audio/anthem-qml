# ButtonGroup

The list selector provides a simple way to create multiple buttons in a group based on Anthem's UI spec.

## Properties

----

### `managementType`

Default: `ButtonGroup.ManagementType.None`

If set to `ButtonGroup.ManagementType.Selector`, this group will act as a tab-style selector, where only one button can be selected at a time. The selected button's index will be reported in `selectedIndex`, and can also be changed by programatically changing `selectedIndex`.

----

### `selectedIndex`

Default: `-1`

If `managementType` is set to `ButtonGroup.ManagementType.Selector`, this property will be set to the index of the currently selected button. Changing this property will update the selected button.

----

### `allowDeselection`

Default: `false`

If `managementType` is set to `ButtonGroup.ManagementType.Selector`, this property will control whether the selected button can be deselected by clicking on it. Deselecting the selected button will set `selectedIndex` to `-1`.

----

### `showBackground`

Default: `true`

Determines if the button graphic should be rendered.

----

### `defaultButtonWidth` and `defaultButtonHeight`

Default: `undefined`

Default width and height. This value will be used if none is provided in the button definition.

----

### `defaultImageWidth` and `defaultImageHeight`

Default: `defaultButtonWidth` and `defaultButtonHeight`, respectively

Default width and height of the image inside the button, if an image has been provided for the button. This value will be used if none is provided in the button definition.

----

### `defaultLeftMargin` and `defaultTopMargin`

Default: `0`

Default spacing to the left and above the button, respectively. This value will be used if none is provided in the button definition.

----

### `defaultInnerMargin`

Default: `undefined`

Default margin value provided to the `Button`. This value will be used if none is provided in the button definition.

----

### `buttonAutoWidth`

Default: `false`

Determines if buttons should automatically size to their content.

----

### `groupHasFixedWidth`

Default: `true`

If true, the container width will remain unset; otherwise, it will be set to the width of the group's content.

----

### `buttons`

The buttons to display.

`buttons` should be a `ListModel` in the following format:

```qml
// Most parameters are optional. The parameters here
// mirror the parameters in Button. See the Button
// documentation for more info.
ButtonGroup {
    buttons: ListModel {
        ListElement {
            // Width of the button
            buttonWidth: real

            // Height of the button
            buttonHeight: real

            // Determines if the button should
            // determine its width based on content.
            // Useful for text buttons.
            autoWidth: bool

            // Space between this button and either
            // the button to its left or the left
            // side of the container.
            leftMargin: real

            // Space between this button and either
            // the button above it or the top of the
            // container.
            topMargin: real

            // Text to display in the button.
            textContent: string

            // Amount of space between the image and
            // the button edges. Used if the width
            // or height are not defiend for this
            // button.
            innerMargin: real

            // Width of the image, if there is one.
            imageWidth: real

            // Height of the image, if there is one.
            imageHeight: real

            // Path to the image to be displayed in
            // this button.
            imageSource: string

            // Message to be shown in the hint panel
            // when the button is hovered.
            hoverMessage: string

            // If true, this button will be an on/off
            // toggle instead of a regular button.
            isToggleButton: bool

            // Called when the button is pressed
            onPress: Function()
        }

        // ...
    }
}
```

## Example

---

```qml
ButtonGroup {
    id: playbackControlsGroup
    anchors.top: parent.top
    anchors.left: idk.right
    anchors.bottom: parent.bottom
    fixedWidth: false
    anchors.leftMargin: 3

    defaultImageWidth: 12
    defaultImageHeight: 12
    defaultButtonWidth: 32
    defaultButtonHeight: 32

    buttons: ListModel {
        ListElement {
            isToggleButton: true
            imageSource: "Images/Play.svg"
        }

        ListElement {
            isToggleButton: true
            hoverMessage: "Record"
            imageSource: "Images/Record.svg"
        }

        ListElement {
            hoverMessage: "Record immediately"
            imageSource: "Images/Play and Record.svg"
            imageWidth: 16
            imageHeight: 16
        }

        ListElement {
            hoverMessage: "Stop"
            imageSource: "Images/Stop.svg"
        }
    }
}
```