#include "project.h"

#include "Utilities/exceptions.h"

Project::Project(Communicator* parent, QSharedPointer<ProjectFile> projectFile) : ModelItem(parent)
{
    jsonNode = &(projectFile->document["project"]);
    transport = new Transport(this, jsonNode);
}
