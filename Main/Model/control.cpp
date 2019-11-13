/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

#include "control.h"

using namespace rapidjson;

#include "Include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/writer.h"

#include <QDebug>

Control::Control(ModelItem* parent, QString name, IdGenerator& idGenerator, float initialValue, float minimum, float maximum, float step) : ModelItem(parent, name) {
    id = idGenerator.get();
    this->initialValue = initialValue;
    ui_currentValue = initialValue;
    this->minimum = minimum;
    this->maximum = maximum;
    this->step = step;
    overrideAutomation = false;
}

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

void Control::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    // The ID is assumed to never change.
    QString initialValueStr = "/initial_value";
    QString overrideAutomationStr = "/override_automation";
    QString minimumStr = "/minimum";
    QString maximumStr = "/maximum";
    QString stepStr = "/step";
    // TODO: control symbol, connection

    if (pointer.startsWith(initialValueStr)) {
        StringBuffer buffer;
        Writer<StringBuffer> writer(buffer);
        patch.patch.Accept(writer);
        qDebug() << buffer.GetString();

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
    Value overrideVal(overrideAutomation);
    Value oldOverrideVal(!overrideAutomation);
    patchReplace("override_automation", oldOverrideVal, overrideVal);
}

// TODO: Set override state depending on whether project is playing or not
void Control::set(float val, bool isFinal) {
    bool changeMade = false;

//    if (!isFinal && !overrideAutomation) {
//        setOverrideState(true);
//        changeMade = true;
//    }

    if (isFinal) {
        auto oldVal = initialValue;
        initialValue = val;
        ui_currentValue = val;
        Value v(val);
        Value vOld(oldVal);
        patchReplace("initial_value", vOld, v);
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
