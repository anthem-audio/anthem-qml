#ifndef MODELITEM_H
#define MODELITEM_H

#include <QSharedPointer>
#include <QObject>

#include "communicator.h"

#include "Include/rapidjson/document.h"

class ModelItem : public Communicator
{
    Q_OBJECT
private:
    QString key;
public:
    ModelItem(Communicator* parent, QString jsonKey);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();
    void liveUpdate(uint64_t controlId, float value);

    rapidjson::Value* jsonNode;
    Communicator* parent;

    virtual ~ModelItem();
};

#endif // MODELITEM_H
