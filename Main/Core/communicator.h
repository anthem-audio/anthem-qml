#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>
#include <QString>

#include "Include/rapidjson/document.h"

class Communicator : public QObject
{
public:
    explicit Communicator(QObject* parent);
    virtual void patch(QString operation, QString from, QString path, rapidjson::Value& value) = 0;
    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
};

#endif // COMMUNICATOR_H
