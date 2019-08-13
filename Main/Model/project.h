#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>
#include <QSharedPointer>

#include "../Include/rapidjson/include/rapidjson/document.h"

#include "../Core/modelitem.h"
#include "../Utilities/documentwrapper.h"

class Project : public QObject, ModelItem
{
    Q_OBJECT
public:
    Project(QObject *parent, QSharedPointer<DocumentWrapper> projectFile);

    int masterPitch;

signals:

public slots:
};

#endif // PROJECT_H
