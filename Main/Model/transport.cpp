#include "transport.h"

Transport::Transport(QObject* parent, rapidjson::Value* projectNode)
{
    this->jsonNode = &(projectNode->operator[]("transport"));
    this->masterPitch = this->jsonNode->operator[]("masterPitch").GetInt();
}

void Transport::setMasterPitch(int pitch) {
    this->masterPitch = pitch;
    this->jsonNode->operator[]("masterPitch") = pitch;
}

int Transport::getMasterPitch() {
    return this->masterPitch;
}
