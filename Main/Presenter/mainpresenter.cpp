#include "mainpresenter.h"

#include "Include/rapidjson/document.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <math.h>

using namespace rapidjson;

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id) : Communicator(parent)
{
    projectHistory = QVector<Patch*>();
    historyPointer = -1;

    isPatchInProgress = false;

    this->id = id;

    isInInitialState = true;

    // Initialize with blank project
    auto projectFile = new ProjectFile(this);
    auto projectModel = new Project(this, projectFile);
    projectFiles.append(projectFile);
    projects.append(projectModel);
    activeProject = projectModel;
    activeProjectIndex = 0;

    // Connect change signals from the model to the UI
    connectUiUpdateSignals(activeProject);

    // Start the engine
    engine = new Engine(dynamic_cast<QObject*>(this));
    engine->start();
}

void MainPresenter::connectUiUpdateSignals(Project* project) {
    QObject::connect(project->transport->masterPitch, SIGNAL(displayValueChanged(float)),
                     this,                            SLOT(ui_updateMasterPitch(float)));
}

void MainPresenter::ui_updateMasterPitch(float pitch) {
    emit masterPitchChanged(static_cast<int>(std::round(pitch)));
}

void MainPresenter::newProject() {
    emit tabAdd("New project");
    // Switch active model, start new engine, switch selected tab
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

    auto projectFile = new ProjectFile(this, path);

    if (isInInitialState) {
        projectFiles[0] = projectFile;
        emit tabRename(0, fileInfo.fileName());
    }
    else {
        projectFiles.append(projectFile);
        emit tabAdd(fileInfo.fileName());
    }

    // TODO: If something goes wrong and this error case trips, the list
    // of project files and project models will become desynced. This
    // should really be solved by creating helper functions to manipulate
    // both lists at once.
    if (projectFile->document.IsNull()) {
        return;
    }

    // Initialize model with JSON
    Project* project = new Project(this, projectFile);
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

    if (historyPointer != projectHistory.length()) {
        for (int i = projectHistory.length() - 1; i >= historyPointer; i--) {
            projectHistory[i]->~Patch();
            projectHistory.pop_back();
        }
    }

    projectHistory.append(
        new Patch(this, activeProject, projectFiles[activeProjectIndex]->document)
    );
}

void MainPresenter::patchAdd(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    Value copiedValue(value, projectFiles[activeProjectIndex]->document.GetAllocator());
    patch.patchAdd("/" + path, copiedValue);
}

void MainPresenter::patchRemove(QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    patch.patchRemove("/" + path);
}

void MainPresenter::patchReplace(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistory[historyPointer];
    Value copiedValue(value, projectFiles[activeProjectIndex]->document.GetAllocator());
    patch.patchReplace("/" + path, copiedValue);
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


void MainPresenter::undo() {
    if (historyPointer == -1)
        return;

    Patch& undoPatch = *projectHistory[historyPointer];
    undoPatch.applyUndo();
    Value& undoPatchVal = undoPatch.getUndoPatch();
    engine->sendPatchList(undoPatchVal);

    historyPointer--;
}

void MainPresenter::redo() {
    if (historyPointer >= projectHistory.length() - 1)
        return;

    historyPointer++;

    Patch& redoPatch = *projectHistory[historyPointer];
    redoPatch.apply();
    engine->sendPatchList(redoPatch.getPatch());
}
