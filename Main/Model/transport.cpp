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

#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, IdGenerator* id) : ModelItem(parent, "transport") {
    this->id = id;
    masterPitch = new Control(this, "master_pitch", *id, 0, -12, 12, 1);
    beatsPerMinute = new Control(this, "beats_per_minute", *id, 140, 10, 999, 0.01f);
    defaultNumerator = 4;
    defaultDenominator = 4;
}

Transport::Transport(ModelItem* parent, IdGenerator* id, Value& transportNode) : ModelItem(parent, "transport")
{
    this->id = id;
    masterPitch = new Control(this, "master_pitch", transportNode["master_pitch"]);
    beatsPerMinute = new Control(this, "beats_per_minute", transportNode["beats_per_minute"]);
    defaultNumerator = static_cast<quint8>(transportNode["default_numerator"].GetUint());
    defaultDenominator = static_cast<quint8>(transportNode["default_denominator"].GetUint());
}

void Transport::onPatchReceived(QStringRef pointer, PatchFragment& patch) {
    QString masterPitchStr = "/master_pitch";
    QString beatsPerMinuteStr = "/beats_per_minute";
    QString defaultNumeratorStr = "/default_numerator";
    QString defaultDenominatorStr = "/default_denominator";
    if (pointer.startsWith(masterPitchStr)) {
        masterPitch->onPatchReceived(pointer.mid(masterPitchStr.length()), patch);
    }
    else if (pointer.startsWith(beatsPerMinuteStr)) {
        beatsPerMinute->onPatchReceived(pointer.mid(beatsPerMinuteStr.length()), patch);
    }
    else if (pointer.startsWith(defaultNumeratorStr)) {
        quint8 val = static_cast<quint8>(patch.patch["value"].GetUint());
        defaultNumerator = val;
        emit numeratorDisplayValueChanged(defaultNumerator);
    }
    else if (pointer.startsWith(defaultDenominatorStr)) {
        quint8 val = static_cast<quint8>(patch.patch["value"].GetUint());
        defaultDenominator = val;
        emit denominatorDisplayValueChanged(defaultDenominator);
    }
}

void Transport::serialize(Value& value, Document& doc) {
    value.SetObject();

    Value masterPitchValue;
    masterPitch->serialize(masterPitchValue, doc);
    value.AddMember("master_pitch", masterPitchValue, doc.GetAllocator());

    Value beatsPerMinuteValue;
    beatsPerMinute->serialize(beatsPerMinuteValue, doc);
    value.AddMember("beats_per_minute", beatsPerMinuteValue, doc.GetAllocator());

    Value numeratorValue(defaultNumerator);
    value.AddMember("default_numerator", numeratorValue, doc.GetAllocator());

    Value denominatorValue(defaultDenominator);
    value.AddMember("default_denominator", denominatorValue, doc.GetAllocator());
}

void Transport::setNumerator(quint8 numerator) {
    auto oldNumerator = defaultNumerator;
    defaultNumerator = numerator;
    Value v(numerator);
    Value vOld(oldNumerator);
    patchReplace("default_numerator", vOld, v);
    sendPatch();
}

quint8 Transport::getNumerator() {
    return defaultNumerator;
}

void Transport::setDenominator(quint8 denominator) {
    auto oldDenominator = defaultDenominator;
    defaultDenominator = denominator;
    Value v(denominator);
    Value vOld(oldDenominator);
    patchReplace("default_denominator", vOld, v);
    sendPatch();
}

quint8 Transport::getDenominator() {
    return defaultDenominator;
}
