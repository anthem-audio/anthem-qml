#include "project.h"

#include <QDebug>

#include "../Utilities/exceptions.h"

Project::Project(QObject *parent, QSharedPointer<DocumentWrapper> projectFile) : QObject(parent)
{
    this->jsonNode = projectFile->document["project"];
    this->masterPitch = this->jsonNode["masterPitch"].GetInt();
    qDebug() << "Master pitch:" << this->masterPitch;
}
