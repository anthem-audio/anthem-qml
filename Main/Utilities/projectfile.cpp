#include "projectfile.h"

#include "../Include/rapidjson/include/rapidjson/filereadstream.h"

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
