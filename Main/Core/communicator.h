#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>
#include <QString>

#include "Include/rapidjson/document.h"

class Communicator : public QObject
{
public:
    explicit Communicator(QObject* parent);
    virtual void sendPatch() = 0;
    virtual void liveUpdate(uint64_t controlId, float value) = 0;
    virtual void patchAdd(QString path, rapidjson::Value& value) = 0;
    virtual void patchRemove(QString path) = 0;
    virtual void patchReplace(QString path, rapidjson::Value& value) = 0;
    virtual void patchCopy(QString from, QString path) = 0;
    virtual void patchMove(QString from, QString path) = 0;
};

#endif // COMMUNICATOR_H
