#include "project.h"

#include "Utilities/exceptions.h"

Project::Project(QObject *parent, QSharedPointer<ProjectFile> projectFile) : QObject(parent)
{
    jsonNode = &(projectFile->document["project"]);
    transport = new Transport(this, jsonNode);
}
