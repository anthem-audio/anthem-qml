#include "project.h"

#include "../Utilities/exceptions.h"

Project::Project(QObject *parent, QSharedPointer<ProjectFile> projectFile) : QObject(parent)
{
    this->jsonNode = &(projectFile->document["project"]);
    this->masterPitch = this->jsonNode->operator[]("transport")["masterPitch"].GetInt();
}

void Project::setMasterPitch(int pitch) {
    this->masterPitch = pitch;
    this->jsonNode->operator[]("transport")["masterPitch"] = pitch;
}

int Project::getMasterPitch() {
    return this->masterPitch;
}
