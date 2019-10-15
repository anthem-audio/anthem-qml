#include "projectfile.h"

#include "Include/rapidjson/filereadstream.h"
#include "Include/rapidjson/filewritestream.h"
#include "Include/rapidjson/writer.h"

ProjectFile::ProjectFile(QObject* parent) : QObject(parent) {
    dirty = false;

    // There's probably a Better Way
    // TODO: Add model constructors that give back a emtpy but valid state
    auto emptyProject =
        "{"
        "    \"software_version\": \"0.0.1\","
        "    \"project\": {"
        "        \"song\": {"
        "            \"patterns\": [],"
        "            \"arrangements\": []"
        "        },"
        "        \"transport\": {"
        "            \"master_pitch\": {"
        "                \"id\": 0,"
        "                \"initial_value\": 0,"
        "                \"minimum\": 12,"
        "                \"maximum\": -12,"
        "                \"step\": 1,"
        "                \"connection\": null,"
        "                \"override_automation\": false"
        "            }"
        "        },"
        "        \"mixer\": {},"
        "        \"generators\": []"
        "    }"
        "}";

    document.Parse(emptyProject);
}

ProjectFile::ProjectFile(QObject* parent, QString path) : QObject(parent) {
    dirty = false;

    this->path = path;

    // Attempt to load the file as JSON
    bool isWindows = QSysInfo::kernelType() == "winnt";

    FILE* fp = std::fopen(path.toUtf8(), isWindows ? "rb" : "r");

    char readBuffer[65536];
    rapidjson::FileReadStream stream(fp, readBuffer, sizeof(readBuffer));

    document.ParseStream(stream);

    fclose(fp);
}

void ProjectFile::save() {
    bool isWindows = QSysInfo::kernelType() == "winnt";
    FILE* fp = std::fopen((path).toUtf8(), isWindows ? "wb" : "w");
    char writeBuffer[65536];
    rapidjson::FileWriteStream stream(fp, writeBuffer, sizeof(writeBuffer));
    rapidjson::Writer<rapidjson::FileWriteStream> writer(stream);
    document.Accept(writer);
    fclose(fp);
    markClean();
}

void ProjectFile::saveAs(QString path) {
    this->path = path;
    save();
}

void ProjectFile::markDirty() {
    dirty = true;
}

void ProjectFile::markClean() {
    dirty = false;
}

bool ProjectFile::isDirty() {
    return dirty;
}
