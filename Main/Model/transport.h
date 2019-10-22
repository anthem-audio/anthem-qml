#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/modelitem.h"
#include "Model/control.h"

class Transport : public ModelItem {
    Q_OBJECT
private:
public:
    Transport(ModelItem* parent, rapidjson::Value& projectNode);
    void externalUpdate(QStringRef pointer, PatchFragment& patch) override;
    void serialize(rapidjson::Value& value, rapidjson::Document& doc) override;

    Control* masterPitch;

signals:

public slots:
};

#endif // TRANSPORT_H
