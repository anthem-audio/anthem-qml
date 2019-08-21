#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>
#include <QSharedPointer>

#include "../Include/rapidjson/include/rapidjson/document.h"

#include "transport.h"

#include "../Core/modelitem.h"
#include "../Utilities/projectfile.h"

class Project : public QObject, ModelItem
{
    Q_OBJECT
private:
public:
    Transport* transport;
    Project(QObject* parent, QSharedPointer<ProjectFile> projectFile);

signals:

public slots:
};

#endif // PROJECT_H
