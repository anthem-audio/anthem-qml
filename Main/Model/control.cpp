#include "control.h"

using namespace rapidjson;

// TODO: controls have names, don't just use "control" when initializing parent ModelItem
Control::Control(ModelItem *parent, Value* controlNode) : ModelItem(parent, "control")
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



void Control::setOverrideState(bool isOverridden) {
    if (overrideAutomation == isOverridden)
        return;

    overrideAutomation = isOverridden;
    jsonNode->operator[]("override_automation") = isOverridden;
    patchReplace("override_automation", jsonNode->operator[]("override_automation"));
}

void Control::set(float val, bool isFinal) {
    if (!isFinal && !overrideAutomation) {
        setOverrideState(true);
    }

    if (isFinal) {
        initialValue = val;
        jsonNode->operator[]("initial_value") = val;
        patchReplace("initial_value", jsonNode->operator[]("initial_value"));
    }
    else {
        liveUpdate(id, val);
    }

    if (isFinal && overrideAutomation) {
        setOverrideState(false);
    }
}

float Control::get() {
    return initialValue;
}
