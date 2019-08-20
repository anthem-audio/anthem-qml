#include "projectfile.h"

#include "../Include/rapidjson/include/rapidjson/filereadstream.h"
#include "../Include/rapidjson/include/rapidjson/filewritestream.h"
#include "../Include/rapidjson/include/rapidjson/writer.h"

ProjectFile::ProjectFile(QString path) {
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
}
