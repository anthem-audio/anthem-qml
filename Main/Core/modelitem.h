#ifndef MODELITEM_H
#define MODELITEM_H

#include <QObject>

#include "communicator.h"
#include "Utilities/patchfragment.h"

#include "Include/rapidjson/document.h"

class ModelItem : public Communicator {
    Q_OBJECT
private:
    QString key;
public:
    /// Apply a patch to the C++ model. Used for undo and redo.
    /// "pointer" is expected to be relative to the ModelItem this
    ///     function is called on.
    virtual void externalUpdate(QStringRef pointer, PatchFragment& patch) = 0;

    /// Serialize model item state into the given value
    virtual void serialize(rapidjson::Value& value, rapidjson::Document& doc) = 0;

    ModelItem(Communicator* parent, QString jsonKey);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path, rapidjson::Value& oldValue);
    void patchReplace(QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();
    void liveUpdate(uint64_t controlId, float value);

    Communicator* parent;

    virtual ~ModelItem();
};

#endif // MODELITEM_H
