#include "project.h"

#include "Utilities/exceptions.h"

Project::Project(Communicator* parent, ProjectFile* projectFile) : ModelItem(parent, "project")
{
    jsonNode = &(projectFile->document["project"]);
    transport = new Transport(this, jsonNode);
}

void Project::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString transportStr = "/transport";
    if (pointer.startsWith(transportStr)) {
        transport->externalUpdate(pointer.mid(transportStr.length()), patch);
    }
}
