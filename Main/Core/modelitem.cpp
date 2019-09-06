#include "modelitem.h"

ModelItem::ModelItem(Communicator* parent, QString jsonKey) : Communicator(static_cast<QObject*>(parent))
{
    this->parent = parent;
    this->key = jsonKey;
}

void ModelItem::patch(QString operation, QString from, QString path, rapidjson::Value &value) {
    parent->patch(
        operation,
        from.isNull() || from.isEmpty() ? from : key + "/" + from,
        key + "/" + path,
        value
    );
}

ModelItem::~ModelItem() {}
