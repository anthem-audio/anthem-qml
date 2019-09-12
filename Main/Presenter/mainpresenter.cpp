#include "mainpresenter.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <cstdio>

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id) : Communicator(parent)
{
    projectHistory = QVector<Patch*>();
    historyPointer = -1;

    isPatchInProgress = false;

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
    return static_cast<int>(activeProject->transport->masterPitch->get() + 0.5f);
}

void MainPresenter::setMasterPitch(int pitch, bool isFinal) {
    activeProject->transport->masterPitch->set(static_cast<float>(pitch), isFinal);
    if (isFinal) {
        emit masterPitchChanged(pitch);
    }
}

// The patch logic below assumes that only one operation
// will happen at once. If two separate model items
// initiate patch builds, they will be grouped together,
// and possibly malformed in some cases, especially when
// it comes to undo/redo.

void MainPresenter::initializeNewPatchIfNeeded() {
    if (isPatchInProgress) {
        return;
    }

    isPatchInProgress = true;

    historyPointer++;

//    if (historyPointer != projectHistory.length()) {
//        projectHistory.remove(historyPointer, projectHistory.length() - historyPointer);
//    }

    projectHistory.append(
        new Patch(this, projectFiles[activeProjectIndex]->document)
    );
}

void MainPresenter::patchAdd(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchAdd("/" + path, value);
}

void MainPresenter::patchRemove(QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchRemove("/" + path);
}

void MainPresenter::patchReplace(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchReplace("/" + path, value);
}

void MainPresenter::patchCopy(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchCopy("/" + from, "/" + path);
}

void MainPresenter::patchMove(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchMove("/" + from, "/" + path);
}

void MainPresenter::sendPatch() {
    if (!isPatchInProgress) {
        throw "sendPatch() was called, but there was nothing to send.";
    }
    Patch& patch = *projectHistory[historyPointer];
    patch.apply();
    engine->sendPatchList(patch.getPatch());
    isPatchInProgress = false;
}

void MainPresenter::liveUpdate(uint64_t controlId, float value) {
    engine->sendLiveControlUpdate(controlId, value);
}
