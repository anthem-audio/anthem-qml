#include "control.h"

using namespace rapidjson;

Control::Control(ModelItem *parent, QString name, Value* controlNode) : ModelItem(parent, name)
{
    jsonNode = controlNode;
    id = controlNode->operator[]("id").GetUint64();
    initialValue = controlNode->operator[]("initial_value").GetFloat();
    minimum = controlNode->operator[]("minimum").GetFloat();
    maximum = controlNode->operator[]("maximum").GetFloat();
    step = controlNode->operator[]("step").GetFloat();
    overrideAutomation = controlNode->operator[]("override_automation").GetBool();
}

// please write constructor for this

// Generate new JSON node and add as field under parentNode
// parentNode[controlName] = {...newly generated control...}



void Control::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    // The ID is assumed to never change.
    QString initialValueStr = "/initial_value";
    QString overrideAutomationStr = "/override_automation";
    QString minimumStr = "/minium";
    QString maximumStr = "/maximum";
    QString stepStr = "/step";
    // TODO: control symbol, connection

    if (pointer.startsWith(initialValueStr)) {
        float val = patch.patch["value"].GetFloat();
        initialValue = val;
        ui_currentValue = val;
        emit displayValueChanged(ui_currentValue);
    }
    else if (pointer.startsWith(overrideAutomationStr)) {
        overrideAutomation = patch.patch["value"].GetBool();
    }
    else if (pointer.startsWith(minimumStr)) {
        minimum = patch.patch["value"].GetBool();
        // TODO: emit update
    }
    else if (pointer.startsWith(maximumStr)) {
        maximum = patch.patch["value"].GetBool();
        // TODO: emit update
    }
    else if (pointer.startsWith(stepStr)) {
        step = patch.patch["value"].GetBool();
        // TODO: emit update
    }
}

void Control::setOverrideState(bool isOverridden) {
    if (overrideAutomation == isOverridden)
        return;

    overrideAutomation = isOverridden;
//    jsonNode->operator[]("override_automation") = isOverridden;
    patchReplace("override_automation", jsonNode->operator[]("override_automation"));
}

// TODO: Set override state depending on whether project is playing or not
void Control::set(float val, bool isFinal) {
    bool changeMade = false;

    if (!isFinal && !overrideAutomation) {
//        setOverrideState(true);
//        changeMade = true;
    }

    if (isFinal) {
        initialValue = val;
        Value v(val);
        patchReplace("initial_value", v);
        changeMade = true;
    }
    else {
        liveUpdate(id, val);
    }

    if (isFinal && overrideAutomation) {
//        setOverrideState(false);
//        changeMade = true;
    }

    if (changeMade) {
        sendPatch();
    }
}

float Control::get() {
    return initialValue;
}
