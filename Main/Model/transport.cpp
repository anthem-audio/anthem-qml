#include "transport.h"

using namespace rapidjson;

Transport::Transport(ModelItem* parent, Value* projectNode) : ModelItem(parent, "transport")
{
    this->jsonNode = &(projectNode->operator[]("transport"));
    this->masterPitch = new Control(this, &this->jsonNode->operator[]("master_pitch"));
}
