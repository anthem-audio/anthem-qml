#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QDebug>
#include <QSysInfo>

#include <cstdio>

#include "../Include/rapidjson/include/rapidjson/document.h"
#include "../Include/rapidjson/include/rapidjson/filereadstream.h"

#include "mainpresenter.h"

MainPresenter::MainPresenter(QObject *parent) : QObject(parent)
{

}

void MainPresenter::loadProject(QString path) {
    // TODO: display errors to user

    QFileInfo fileInfo(path);

    // Check if the path exists and is a file
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        return;
    }

    // Ensure the file ends with ".anthem"
    if (fileInfo.suffix() != "anthem") {
        return;
    }

    // Attempt to load the file as JSON
    bool isWindows = QSysInfo::kernelType() == "winnt";

    FILE* fp = std::fopen(path.toUtf8(), isWindows ? "rb" : "r");

    char readBuffer[65536];
    rapidjson::FileReadStream stream(fp, readBuffer, sizeof(readBuffer));

    rapidjson::Document json;
    json.ParseStream(stream);

    fclose(fp);

    if (json.IsNull()) {
        return;
    }

    // Initialize model with JSON
}
