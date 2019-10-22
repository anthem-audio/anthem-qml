#include "control.h"

using namespace rapidjson;

Control::Control(ModelItem *parent, QString name, Value& controlNode) : ModelItem(parent, name)
{
    id = controlNode["id"].GetUint64();
    initialValue = controlNode["initial_value"].GetFloat();
    ui_currentValue = initialValue;
    minimum = controlNode["minimum"].GetFloat();
    maximum = controlNode["maximum"].GetFloat();
    step = controlNode["step"].GetFloat();
    overrideAutomation = controlNode["override_automation"].GetBool();
}

// please write constructor for this

// Generate new JSON node and add as field under parentNode
// parentNode[controlName] = {...newly generated control...}



void Control::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    // The ID is assumed to never change.
    QString initialValueStr = "/initial_value";
    QString overrideAutomationStr = "/override_automation";
    QString minimumStr = "/minimum";
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
        minimum = patch.patch["value"].GetFloat();
        // TODO: emit update
    }
    else if (pointer.startsWith(maximumStr)) {
        maximum = patch.patch["value"].GetFloat();
        // TODO: emit update
    }
    else if (pointer.startsWith(stepStr)) {
        step = patch.patch["value"].GetFloat();
        // TODO: emit update
    }
}

void Control::serialize(rapidjson::Value& value, rapidjson::Document& doc) {
    value.SetObject();

    value.AddMember("id", id, doc.GetAllocator());
    value.AddMember("initial_value", initialValue, doc.GetAllocator());
    value.AddMember("minimum", minimum, doc.GetAllocator());
    value.AddMember("maximum", maximum, doc.GetAllocator());
    value.AddMember("step", step, doc.GetAllocator());
    value.AddMember("override_automation", overrideAutomation, doc.GetAllocator());
    value.AddMember("connection", kNullType, doc.GetAllocator());
}

void Control::setOverrideState(bool isOverridden) {
    if (overrideAutomation == isOverridden)
        return;

    overrideAutomation = isOverridden;
//    jsonNode->operator[]("override_automation") = isOverridden;
    Value overrideVal(overrideAutomation);
    patchReplace("override_automation", overrideVal);
}

// TODO: Set override state depending on whether project is playing or not
void Control::set(float val, bool isFinal) {
    bool changeMade = false;

//    if (!isFinal && !overrideAutomation) {
//        setOverrideState(true);
//        changeMade = true;
//    }

    if (isFinal) {
        initialValue = val;
        ui_currentValue = val;
        Value v(val);
        patchReplace("initial_value", v);
        changeMade = true;
    }
    else {
        liveUpdate(id, val);
        ui_currentValue = val;
    }

//    if (isFinal && overrideAutomation) {
//        setOverrideState(false);
//        changeMade = true;
//    }

    if (changeMade) {
        sendPatch();
    }
}

float Control::get() {
    // ui_currentValue should always be the most up-to-date.
    return ui_currentValue;
}
