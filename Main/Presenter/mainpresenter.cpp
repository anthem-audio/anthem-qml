#include "mainpresenter.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QDebug>
#include <QSysInfo>

#include <cstdio>

#include "../Include/rapidjson/include/rapidjson/filereadstream.h"

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

    auto i = projectFiles.length();

    projectFiles.append(QSharedPointer<DocumentWrapper>(new DocumentWrapper()));

    projectFiles[i]->document.ParseStream(stream);

    fclose(fp);

    if (projectFiles[i]->document.IsNull()) {
        return;
    }

    // Initialize model with JSON
    QSharedPointer<Project> project = QSharedPointer<Project>(new Project(this, projectFiles[i]));
    projects.append(project);
    activeProject = project;

    updateAll();
}

void MainPresenter::updateAll() {
    emit masterPitchChanged(getMasterPitch());
}

int MainPresenter::getMasterPitch() {
    return activeProject->masterPitch;
}

void MainPresenter::setMasterPitch(int pitch) {

}
