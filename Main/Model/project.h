#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/communicator.h"
#include "transport.h"
#include "Core/modelitem.h"

class Project : public ModelItem {
    Q_OBJECT
private:
    IdGenerator* id;
public:
    Transport* transport;
    Project(Communicator* parent, IdGenerator* id);
    Project(Communicator* parent, IdGenerator* id, rapidjson::Value& projectVal);

    void externalUpdate(QStringRef pointer, PatchFragment& patch) override;

    void serialize(rapidjson::Value& value, rapidjson::Document& doc) override;

signals:

public slots:
};

#endif // PROJECT_H
