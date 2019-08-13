#include "mainpresenter.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QDebug>
#include <QSysInfo>

#include <cstdio>

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

    auto i = projectFiles.length();

    projectFiles.append(QSharedPointer<ProjectFile>(new ProjectFile(path)));

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
