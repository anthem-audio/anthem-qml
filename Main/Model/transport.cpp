#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value& projectNode) : ModelItem(parent, "transport")
{
    masterPitch = new Control(this, "master_pitch", projectNode["master_pitch"]);
    beatsPerMinute = new Control(this, "beats_per_minute", projectNode["beats_per_minute"]);
}

void Transport::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString masterPitchStr = "/master_pitch";
    QString beatsPerMinuteStr = "/beats_per_minute";
    if (pointer.startsWith(masterPitchStr)) {
        masterPitch->externalUpdate(pointer.mid(masterPitchStr.length()), patch);
    }
    else if (pointer.startsWith(beatsPerMinuteStr)) {
        beatsPerMinute->externalUpdate(pointer.mid(beatsPerMinuteStr.length()), patch);
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
}
