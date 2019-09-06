#include "control.h"

// TODO: controls have names, don't just use "control" when initializing parent ModelItem
Control::Control(ModelItem *parent, rapidjson::Value* controlNode) : ModelItem(parent, "control")
{
    jsonNode = controlNode;
    initialValue = controlNode->operator[]("initial_value").GetFloat();
    minimum = controlNode->operator[]("minimum").GetFloat();
    maximum = controlNode->operator[]("maximum").GetFloat();
    step = controlNode->operator[]("step").GetFloat();
    overrideAutomation = controlNode->operator[]("override_automation").GetBool();
}

// please write constructor for this

// Generate new JSON node and add as field under parentNode
// parentNode[controlName] = {...newly generated control...}
