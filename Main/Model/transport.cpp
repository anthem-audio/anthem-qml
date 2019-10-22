#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value& projectNode) : ModelItem(parent, "transport")
{
    masterPitch = new Control(this, "master_pitch", projectNode["master_pitch"]);
}

void Transport::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString masterPitchStr = "/master_pitch";
    if (pointer.startsWith(masterPitchStr)) {
        masterPitch->externalUpdate(pointer.mid(masterPitchStr.length()), patch);
    }
}

void Transport::serialize(Value& value, Document& doc) {
    value.SetObject();

    Value masterPitchValue;
    masterPitch->serialize(masterPitchValue, doc);
    value.AddMember("master_pitch", masterPitchValue, doc.GetAllocator());
}
