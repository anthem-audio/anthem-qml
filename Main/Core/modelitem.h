#ifndef MODELITEM_H
#define MODELITEM_H

#include <QSharedPointer>
#include <QObject>

#include "communicator.h"

#include "Include/rapidjson/document.h"

class ModelItem : public Communicator
{
    Q_OBJECT
public:
    ModelItem(Communicator* parent);

    rapidjson::Value* jsonNode;
    Communicator* parent;

    virtual ~ModelItem();
};

#endif // MODELITEM_H
