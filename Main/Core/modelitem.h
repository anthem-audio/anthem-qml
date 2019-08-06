#ifndef MODELITEM_H
#define MODELITEM_H

#include "../Include/rapidjson/include/rapidjson/document.h"

class ModelItem
{
public:
    ModelItem();
    rapidjson::Value GetJsonNode();

    rapidjson::Value jsonNode;
};

#endif // MODELITEM_H
