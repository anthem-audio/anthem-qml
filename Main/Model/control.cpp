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
