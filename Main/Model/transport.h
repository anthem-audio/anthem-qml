#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <QObject>

#include "Include/rapidjson/include/rapidjson/document.h"

#include "Core/modelitem.h"

class Transport : public QObject, ModelItem
{
private:
    int masterPitch;
public:
    Transport(QObject* parent, rapidjson::Value* projectNode);

    void setMasterPitch(int pitch);
    int getMasterPitch();

signals:

public slots:
};

#endif // TRANSPORT_H
