#include "transport.h"

Transport::Transport(ModelItem* parent, rapidjson::Value* projectNode) : ModelItem(parent)
{
    this->jsonNode = &(projectNode->operator[]("transport"));
    this->masterPitch = this->jsonNode->operator[]("master_pitch").GetInt();
}

void Transport::setMasterPitch(int pitch) {
    this->masterPitch = pitch;
    this->jsonNode->operator[]("master_pitch") = pitch;
}

int Transport::getMasterPitch() {
    return this->masterPitch;
}
