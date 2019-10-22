#include "project.h"

#include "Utilities/exceptions.h"

Project::Project(Communicator* parent, rapidjson::Value& projectVal) : ModelItem(parent, "project") {
    transport = new Transport(this, projectVal["transport"]);
}

void Project::externalUpdate(QStringRef pointer, PatchFragment& patch) {
    QString transportStr = "/transport";
    if (pointer.startsWith(transportStr)) {
        transport->externalUpdate(pointer.mid(transportStr.length()), patch);
    }
}

void Project::serialize(rapidjson::Value& value, rapidjson::Document& doc) {
    value.SetObject();

    rapidjson::Value transportValue;
    transport->serialize(transportValue, doc);
    value.AddMember("transport", transportValue, doc.GetAllocator());
}
