#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value* projectNode) : ModelItem(parent, "transport")
{
    this->jsonNode = &(projectNode->operator[]("transport"));
    this->masterPitch = this->jsonNode->operator[]("master_pitch").GetInt();
}

void Transport::setMasterPitch(int pitch) {
    this->masterPitch = pitch;
    this->jsonNode->operator[]("master_pitch") = pitch;

    Value pitchVal(kNumberType);
    pitchVal = pitch;

    patchReplace("master_pitch", pitchVal);
}

int Transport::getMasterPitch() {
    return this->masterPitch;
}
