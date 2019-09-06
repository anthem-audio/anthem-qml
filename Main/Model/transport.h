#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/modelitem.h"

class Transport : public ModelItem
{
    Q_OBJECT
private:
    int masterPitch;
public:
    Transport(ModelItem* parent, rapidjson::Value* projectNode);

    void setMasterPitch(int pitch);
    int getMasterPitch();

signals:

public slots:
};

#endif // TRANSPORT_H
