#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value& projectNode) : ModelItem(parent, "transport")
{
    masterPitch = new Control(this, "master_pitch", projectNode["master_pitch"]);
    beatsPerMinute = new Control(this, "beats_per_minute", projectNode["beats_per_minute"]);
    defaultNumerator = static_cast<quint8>(projectNode["default_numerator"].GetUint());
    defaultDenominator = static_cast<quint8>(projectNode["default_denominator"].GetUint());
}

void Transport::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString masterPitchStr = "/master_pitch";
    QString beatsPerMinuteStr = "/beats_per_minute";
    QString defaultNumeratorStr = "/default_numerator";
    QString defaultDenominatorStr = "/default_denominator";
    if (pointer.startsWith(masterPitchStr)) {
        masterPitch->externalUpdate(pointer.mid(masterPitchStr.length()), patch);
    }
    else if (pointer.startsWith(beatsPerMinuteStr)) {
        beatsPerMinute->externalUpdate(pointer.mid(beatsPerMinuteStr.length()), patch);
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
    defaultNumerator = numerator;
    Value v(numerator);
    patchReplace("default_numerator", v);
    sendPatch();
}

quint8 Transport::getNumerator() {
    return defaultNumerator;
}

void Transport::setDenominator(quint8 denominator) {
    defaultDenominator = denominator;
    Value v(denominator);
    patchReplace("default_denominator", v);
    sendPatch();
}

quint8 Transport::getDenominator() {
    return defaultDenominator;
}
