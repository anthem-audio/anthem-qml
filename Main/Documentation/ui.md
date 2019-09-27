# User interface

## Table of contents
- [User interface](#user-interface)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
    - [The UI and the engine are separate](#the-ui-and-the-engine-are-separate)
  - [The model](#the-model)
  - [Tutorial: adding a global control](#tutorial-adding-a-global-control)
    - [Step 1: the UI](#step-1-the-ui)
    - [Step 2: the data](#step-2-the-data)
    - [Step 3: tying it all together](#step-3-tying-it-all-together)

## Overview

The UI is written in QML and C++ and follows a loose interpretation of the [model-view-presenter (MVP)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93presenter) design pattern. In our interpretation of MVP, the following is true:

- The C++ model is strictly for handling data storage, retrieval, and serialization.
- The QML view handles data display and user interaction.
- The presenter connects the view to the model and houses any application logic (for example, saving and loading) that is not directly related to manipulating the UI.

### The UI and the engine are separate

In Anthem, the UI and the engine are separate. They have separate code bases, run in separate processes, and are developed almost entirely apart from each other.

The UI communicates with the engine using [JSON-RPC](https://www.jsonrpc.org/specification) messages. These messages are sent and received over the engine's `stdin` and `stdout`.

The UI is authoratative. This means that the UI (and the user by extension) always tells the engine what to do, and never the other way around.

This architecture has a few unique advantages:

- Multiple projects can be open at one time without the engine ever needing to know about it. If the UI wants to open a new project in a new tab, it just needs to spawn a new engine.
- The engine doesn't even need to be running on a project for the project to be open. If the user's sysetm can't handle having multiple engines running, they can stop one of the engines while still keeping the UI available for viewing, editing, and copying project data.
- Separation of concerns between the UI and the engine isn't just preferred; it's enforced, since the engine is in a separate process.

## The model

Each piece of data in the data model is stored twice: once in C++, and once in JSON. This may seem redundant at first, but each piece has its own role. The C++ model gives us a convenient place to put the logic for direct data manipulation, is hirearchical, and is highly scalable. The JSON representation mirrors the C++ representation, and is always kept up-to-date. We use rapidjson for the JSON representation, so serialization is efficient (linear time) and implicit (the model code doesn't need to worry about serialization).

Changes to the model are described with and applied from [JSON Patch](http://jsonpatch.com) messages. This is the format in which changes are sent to the engine, and undos/redos are stored this way as well. When the user changes a value, the UI calls a function in the presenter, which then calls a function in the model. The model then builds a patch message and uses it to apply the change to the JSON model and the engine. In the case of undo/redo, the change still originates from a patch, but the patch is used to update the C++ model as well.

## Tutorial: adding a global control

For this tutorial, we will see how to add a control and connect it to the model. The control type we will use here is a `DigitControl`, but any control type will work.

`DigitControl` is used for tempo, time signature, and master pitch, among other things.

Just a note before we get started: this tutorial does not cover controls that are dynamically added and removed from the UI. The control we're adding here is assumed to be accessable from a single, constant path, and it should only exist in one place in the project. You will need extra steps if you want to make a control for a generator or a mixer channel, since there can be multiple generators and mixer channels in one project.

### Step 1: the UI

First, add the following QML code. This will add  numeric selector to the UI, but it won't be connected to anything for now:

```qml
DigitControl {
    id: myDigitControl

    // Be sure to set appropreate size and/or anchors.
    // I'm just going to fill the parent. :)
    anchors.fill: parent

    lowBound: 0
    highBound: 100

    onValueChanged: {

    }

    onValueChangeCompleted: {

    }

    Connections {

    }
}
```

### Step 2: the data

Next, we need a place in the model for our new control. The `Control` class is a generic class for representing any automatable control in the data model, and this is the class we will use to represent our new `DigitControl`.

> A quick sidenote about inheritance in the model: `Control` inherits from `ModelItem`, which takes care of a few features common to all items in the model. `ModelItem` inherits from `Communicator`, which provides a way for model items to send messages up the tree, with the path being generated along the way. Understanding how this happens isn't crucial, but you can dig into the code if you're curious about the plumbing behind everything.

We will be putting our new control directly in the `Project` class, but you could add it to any class that inherits from `ModelItem`. `Project` is the highest `ModelItem` in the project tree, and everything in a project lives inside it.

Change `Model/project.h` so it looks something like this:

```c++
class Project : public ModelItem {
    //...
public:
    Control* myDigitControl;
}
```

That's all we need to do in the header. Now, in `Model/project.cpp`, we need to initialize our new control and connect it to the rest of the model. There two steps involved:

1. Initialize `myDigitControl` in the constructor. The constructor for `Control` takes 3 arguments:
    - The `Control`'s parent, required by `QObject`
    - The name of (or path to) the control in the model
    - A pointer to the corresponding node in the JSON

```c++
Project::Project(Communicator* parent, ProjectFile* projectFile) : ModelItem(parent, "project") {
    //...
    myDigitControl = new Control(this, "my_digit_control", &jsonNode->operator[]("my_digit_control"));
}
```

2. Modify `Project::externalUpdate()`. This function handles JSON Patch updates that originate from outside the model (externally), hence the name.

```c++
void Transport::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    //...
    QString myDigitControlStr = "/my_digit_control";
    
    //...
    else if (pointer.startsWith(myDigitControlStr)) {
        myDigitControl->externalUpdate(pointer.mid(myDigitControlStr.length()), patch);
    }
}
```

> If you're new to Qt but not to C++, you may have gotten a bit worried at the usage of `new` without a corresponding `delete`. We can do this because `Control` is a `QObject`, and `QObject`s are automatically destructed and cleaned up when their parent is. When the user closes a project, `someProject.~Project()` is called, and the entire model for that project is destructed and cleaned up automatically by Qt.

Finally, we need to update the default empty project with our new control. Right now, this project is located directly in `Utilities/projectfile.cpp`, but it will eventaully be moved to its own `.anthem` file. The updated project file should look something like this:

```json
{
    "software_version": "0.0.1",
    "project": {
        "my_digit_control": {
            "id": 1928375, // must be unique
            "initial_value": 0,
            "minimum": 0,
            "maximum": 100,
            "step": 1,
            "connection": null,
            "override_automation": false
        }
        
        "song": {
            ...
        }
        "transport": {
            ...
        }
        ...
    }
}
```

### Step 3: tying it all together

We have a control in the QML, and we have a control in the model, but they're not connected. Let's fix that.

This is where the presenter comes in. The presenter is where all the connecting pieces go. The UI doesn't have direct access to the model; instead, it calls functions in the presenter, which in turn manipulate the model.

In `Presenter/mainpresenter.h`, add the following code:

```c++
class MainPresenter : public Communicator {
    //...
signals:
    //...
    myDigitControlChanged(int value);

slots:
    //...

    // Getters and setters for model properties
    //...
    int getMyDigitControl();
    void setMyDigitControl(int value, bool isFinal);

    //...

    ui_updateMyDigitControl(float value); // all controls are stored internally as floats
}
```

`isFinal` will be used to determine whether to just send a live update to the engine (`isFinal == false`), or whether to send a patch to the engine and generate an undo step (`isFinal == true`).

Next, fill out/update the functions in `Presenter/mainpresenter.cpp`:

```c++
void MainPresenter::connectUiUpdateSignals(Project* project) {
    //...
    QObject::connect(project->myDigitControl, SIGNAL(displayValueChanged(float)),
                     this,                    SLOT(ui_updateMyDigitControl(float)));
}

void MainPresenter::disconnectUiUpdateSignals(Project* project) {
    //...
    QObject::disconnect(project->myDigitControl, SIGNAL(displayValueChanged(float)),
                        this,                    SLOT(ui_updateMyDigitControl(float)));
}

void MainPresenter::ui_updateMyDigitControl(float value) {
    //...
    emit myDigitControlChanged(static_cast<int>(std::round(value)));
}

void MainPresenter::updateAll() {
    //...
    emit myDigitControlChanged(getMyDigitControl());
}

int MainPresenter::getMyDigitControl() {
    return static_cast<int>(std::round(projects[activeProjectIndex]->myDigitControl->get()));
}

void MainPresenter::setMyDigitControl(int value, bool isFinal) {
    projects[activeProjectIndex]->myDigitControl->set(static_cast<float>(value), isFinal);
    if (isFinal) {
        emit myDigitControlChanged(value);
    }
}
```

And finally, to tie it all together, we're going back to the QML. Remember those functions we left empty? It's time to fill them in:

```qml
DigitControl {
    id: myDigitControl

    // Be sure to set appropreate size and/or anchors.
    // I'm just going to fill the parent. :)
    anchors.fill: parent

    lowBound: 0
    highBound: 100

    onValueChanged: {
        Anthem.setMyDigitControl(value, false);
    }

    onValueChangeCompleted: {
        Anthem.setMyDigitControl(value, true);
    }

    Connections {
        target: Anthem
        onMyDigitControlChanged {
            myDigitControl.value = value;
        }
    }
}
```

`Anthem` refers to an instance of `MainPresenter`.

And that's it! You should now have a working `DigitControl` that responds properly to undo/redo and is automatically saved and loaded with the project.