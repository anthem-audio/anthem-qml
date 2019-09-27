#include "modelitem.h"

ModelItem::ModelItem(Communicator* parent, QString jsonKey) : Communicator(static_cast<QObject*>(parent))
{
    this->parent = parent;
    this->key = jsonKey;
}

ModelItem::~ModelItem() {}

void ModelItem::patchAdd(QString path, rapidjson::Value& value) {
    parent->patchAdd(
        key + "/" + path,
        value
    );
}

void ModelItem::patchRemove(QString path) {
    parent->patchRemove(
        key + "/" + path
    );
}

void ModelItem::patchReplace(QString path, rapidjson::Value& value) {
    parent->patchReplace(
        key + "/" + path,
        value
    );
}

void ModelItem::patchCopy(QString from, QString path) {
    parent->patchCopy(
        key + "/" + from,
        key + "/" + path
    );
}

void ModelItem::patchMove(QString from, QString path) {
    parent->patchMove(
        key + "/" + from,
        key + "/" + path
    );
}

void ModelItem::sendPatch() {
    parent->sendPatch();
}

void ModelItem::liveUpdate(uint64_t controlId, float value) {
    parent->liveUpdate(controlId, value);
}
