#include "project.h"

#include <QDebug>

#include "../Utilities/exceptions.h"

Project::Project(QObject *parent, QSharedPointer<ProjectFile> projectFile) : QObject(parent)
{
    this->jsonNode = projectFile->document["project"];
    this->masterPitch = this->jsonNode["masterPitch"].GetInt();
    qDebug() << "Master pitch:" << this->masterPitch;
}
