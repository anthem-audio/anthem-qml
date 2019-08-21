#ifndef MODELITEM_H
#define MODELITEM_H

#include <QSharedPointer>

#include "Include/rapidjson/include/rapidjson/document.h"

class ModelItem
{
public:
    ModelItem();

    rapidjson::Value* jsonNode;
};

#endif // MODELITEM_H
