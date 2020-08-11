/*
    Copyright (C) 2019, 2020 Joshua Wade

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
#include "qdebug.h"

Control::Control(
            ModelItem* parent,
            QString name,
            IdGenerator& idGenerator,
            float initialValue,
            float minimum,
            float maximum,
            float step
        ) : ModelItem(parent, name)
{
    id = idGenerator.get();
    this->initialValue = initialValue;
    ui_currentValue = initialValue;
    this->minimum = minimum;
    this->maximum = maximum;
    this->step = step;
    overrideAutomation = false;
}

Control::Control(
    ModelItem *parent,
    QString name,
    QJsonObject& node
) : ModelItem(parent, name)
{
    // TODO: throw an error if this is false after the conversion
    bool ok;
    id = static_cast<quint64>(
                node["id"].toString().toULongLong(&ok, 10)
            );

    initialValue = static_cast<float>(
                node["initial_value"].toDouble()
            );
    ui_currentValue = initialValue;

    minimum = static_cast<float>(node["minimum"].toDouble());
    maximum = static_cast<float>(node["maximum"].toDouble());
    step = static_cast<float>(node["step"].toDouble());
    overrideAutomation = node["override_automation"].toBool();

    qDebug() << node;
}

void Control::serialize(QJsonObject& node) {
    node["id"] = QString::number(id);
    node["initial_value"] = static_cast<double>(initialValue);
    node["minimum"] = static_cast<double>(minimum);
    node["maximum"] = static_cast<double>(maximum);
    node["step"] = static_cast<double>(step);
    node["override_automation"] = overrideAutomation;
    node["connection"] = QJsonValue::Null;
}

void Control::setOverrideState(bool isOverridden) {
    if (overrideAutomation == isOverridden)
        return;

    overrideAutomation = isOverridden;
    QJsonValue overrideVal(overrideAutomation);
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
        QJsonValue v(static_cast<double>(val));
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
