#include "mainpresenter.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <cstdio>

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id) : Communicator(parent)
{
    this->id = id;

    isInInitialState = true;

    // Initialize with blank project
    auto projectFile = QSharedPointer<ProjectFile>(new ProjectFile());
    auto projectModel = QSharedPointer<Project>(new Project(this, projectFile));
    projectFiles.append(projectFile);
    projects.append(projectModel);
    activeProject = projectModel;
    activeProjectIndex = 0;

    // Start the engine
    engine = new Engine(dynamic_cast<QObject*>(this));
    engine->start();
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

    auto projectFile = QSharedPointer<ProjectFile>(new ProjectFile(path));

    if (isInInitialState)
        projectFiles[0] = projectFile;
    else
        projectFiles.append(projectFile);

    // TODO: If something goes wrong and this error case trips, the list
    // of project files and project models will become desynced. This
    // should really be solved by creating helper functions to manipulate
    // both lists at once.
    if (projectFile->document.IsNull()) {
        return;
    }

    // Initialize model with JSON
    QSharedPointer<Project> project = QSharedPointer<Project>(new Project(this, projectFile));
    if (isInInitialState) {
        projects[0] = project;
        activeProjectIndex = 0;
    }
    else {
        projects.append(project);
        activeProjectIndex = i;
    }
    activeProject = project;

    updateAll();

    isInInitialState = false;
}

void MainPresenter::updateAll() {
    emit masterPitchChanged(getMasterPitch());
}

void MainPresenter::saveActiveProject() {
    projectFiles[activeProjectIndex]->save();
}

int MainPresenter::getMasterPitch() {
    return activeProject->transport->getMasterPitch();
}

void MainPresenter::setMasterPitch(int pitch, bool isFinal) {
    activeProject->transport->setMasterPitch(pitch);
    if (isFinal) {
        emit masterPitchChanged(pitch);
    }
}

void MainPresenter::patch(QString operation, QString from, QString path, rapidjson::Value &value) {
    engine->sendPatch(operation, from, path, value);
}
