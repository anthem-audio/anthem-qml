#include "communicator.h"

using namespace rapidjson;

Communicator::Communicator(QObject* parent) : QObject(parent) {

}

void Communicator::patchAdd(QString path, Value &value) {
    patch("add", QString(), path, value);
}

void Communicator::patchRemove(QString path) {
    Value value(kNullType);
    patch("remove", QString(), path, value);
}

void Communicator::patchReplace(QString path, Value &value) {
    patch("replace", QString(), path, value);
}

void Communicator::patchCopy(QString from, QString path) {
    Value value(kNullType);
    patch("copy", from, path, value);
}

void Communicator::patchMove(QString from, QString path) {
    Value value(kNullType);
    patch("move", from, path, value);
}
