#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>
#include <QSharedPointer>

#include "../Include/rapidjson/include/rapidjson/document.h"

#include "../Core/modelitem.h"
#include "../Utilities/projectfile.h"

class Project : public QObject, ModelItem
{
    Q_OBJECT
private:
    int masterPitch;
public:
    Project(QObject *parent, QSharedPointer<ProjectFile> projectFile);

    void setMasterPitch(int pitch);
    int getMasterPitch();

signals:

public slots:
};

#endif // PROJECT_H
