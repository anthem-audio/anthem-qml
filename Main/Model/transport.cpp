#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value* projectNode) : ModelItem(parent, "transport")
{
    jsonNode = &(projectNode->operator[]("transport"));
    masterPitch = new Control(this, "master_pitch", &jsonNode->operator[]("master_pitch"));
}

void Transport::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString masterPitchStr = "/master_pitch";
    if (pointer.startsWith(masterPitchStr)) {
        masterPitch->externalUpdate(pointer.mid(masterPitchStr.length()), patch);
    }
}
