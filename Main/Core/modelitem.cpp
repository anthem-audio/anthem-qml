#include "modelitem.h"

ModelItem::ModelItem()
{
    this->jsonNode.SetObject();
}

rapidjson::Value ModelItem::GetJsonNode() {
    return this->jsonNode.GetObject();
}
