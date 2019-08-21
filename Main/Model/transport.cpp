#include "transport.h"

Transport::Transport(QObject* parent, rapidjson::Value* projectNode) : QObject(parent)
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
