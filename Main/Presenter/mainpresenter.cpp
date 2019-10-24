#include "mainpresenter.h"

#include "Include/rapidjson/document.h"
#include "Utilities/exceptions.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <math.h>

using namespace rapidjson;

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id) : Communicator(parent) {
    isPatchInProgress = false;
    isActiveProjectValid = true;

    this->id = id;

    isInInitialState = true;

    // Initialize with blank project
    auto projectFile = new ProjectFile(this);
    auto projectModel = new Project(this, projectFile->document["project"]);
    activeProjectIndex = 0;

    // Connect change signals from the model to the UI
    connectUiUpdateSignals(projectModel);

    // Start the engine
    auto engine = new Engine(dynamic_cast<QObject*>(this));
    engine->start();

    addProject(projectModel, projectFile, engine);
}

void MainPresenter::addProject(Project* project, ProjectFile* projectFile, Engine* engine) {
    projects.append(project);
    projectFiles.append(projectFile);
    engines.append(engine);
    projectHistories.append(QVector<Patch*>());
    historyPointers.append(-1);
}

Project* MainPresenter::getProjectAt(int index) {
    return projects[index];
}

ProjectFile* MainPresenter::getProjectFileAt(int index) {
    return projectFiles[index];
}

Engine* MainPresenter::getEngineAt(int index) {
    return engines[index];
}

QVector<Patch*> MainPresenter::getProjectHistoryAt(int index) {
    return projectHistories[index];
}

int MainPresenter::getHistoryPointerAt(int index) {
    return historyPointers[index];
}

void MainPresenter::removeProjectAt(int index) {
    projects[index]->~Project();
    projectFiles[index]->~ProjectFile();
    engines[index]->~Engine();

    projects.removeAt(index);
    projectFiles.removeAt(index);
    engines.removeAt(index);
    historyPointers.removeAt(index);

    for (int i = 0; i < projectHistories[index].length(); i++) {
        projectHistories[index][i]->~Patch();
    }

    projectHistories.removeAt(index);

    // If the active project is closed, the index will be set to -1.
    if (index == activeProjectIndex) {
        isActiveProjectValid = false;
        activeProjectIndex = -1;
    }
    // This prevents the active project index from becoming desynced in
    // cases where the active projct is positioned after the tab that was
    // closed.
    else if (index < activeProjectIndex) {
        activeProjectIndex--;
    }
}

void MainPresenter::connectUiUpdateSignals(Project* project) {
    QObject::connect(project->transport->masterPitch, SIGNAL(displayValueChanged(float)),
                     this,                            SLOT(ui_updateMasterPitch(float)));
}

// This should mirror the function above
void MainPresenter::disconnectUiUpdateSignals(Project* project) {
    QObject::disconnect(project->transport->masterPitch, SIGNAL(displayValueChanged(float)),
                        this,                            SLOT(ui_updateMasterPitch(float)));
}

void MainPresenter::ui_updateMasterPitch(float pitch) {
    emit masterPitchChanged(static_cast<int>(std::round(pitch)));
}

void MainPresenter::newProject() {
    auto projectFile = new ProjectFile(this);
    auto projectModel = new Project(this, projectFile->document["project"]);
    auto engine = new Engine(this);
    engine->start();
    addProject(projectModel, projectFile, engine);
    switchActiveProject(projects.length() - 1);
    emit tabAdd("New project");
    emit tabSelect(activeProjectIndex);
    isInInitialState = false;
}

void MainPresenter::loadProject(QString path) {
    QFileInfo fileInfo(path);

    // Check if the path exists and is a file
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        emit informationDialogRequest("Error", "That project does not exist.");
        return;
    }

    // Ensure the file ends with ".anthem"
    if (fileInfo.suffix() != "anthem") {
        emit informationDialogRequest("Error", "That is not a *.anthem file. If you think the file you chose is valid, please rename it so it has a \".anthem\" extension.");
        return;
    }

    ProjectFile* projectFile;

    try {
        projectFile = new ProjectFile(this, path);
    }
    catch (const InvalidProjectException& ex) {
        emit informationDialogRequest("Error", QString(ex.what()));
        return;
    }

    QString fileName = fileInfo.fileName();
    fileName.chop(fileInfo.completeSuffix().length() + 1);

    if (isInInitialState) {
        removeProjectAt(0);
    }

    if (projectFile->document.IsNull()) {
        // This should never trip and will be removed in a future PR.
        emit informationDialogRequest("Error", "Something is very wrong.");
        projectFile->~ProjectFile();
        return;
    }

    Project* project;

    try {
        // Initialize model with JSON
        project = new Project(this, projectFile->document["project"]);
    }
    catch (const InvalidProjectException& ex) {
        QString errorText = "The project file failed to load. ";
        emit informationDialogRequest("Error", errorText.append(ex.what()));
        projectFile->~ProjectFile();
        return;
    }

    // Create and start new engine
    // TODO: Once engines can be stared and stopped by the user, don't start immediately. (?)
    // TODO: Engine may have errors when starting. Report these to the user.
    Engine* engine = new Engine(this);
    engine->start();

    addProject(project, projectFile, engine);
    switchActiveProject(projects.length() - 1);

    if (isInInitialState) {
        emit tabRename(0, fileName);
    }
    else {
        emit tabAdd(fileName);
        emit tabSelect(getNumOpenProjects() - 1);
    }

    isInInitialState = false;
}

void MainPresenter::saveActiveProject() {
    projectFiles[activeProjectIndex]->save(*projects[activeProjectIndex]);
}

void MainPresenter::saveActiveProjectAs(QString path) {
    projectFiles[activeProjectIndex]->saveAs(*projects[activeProjectIndex], path);
    QFileInfo fileInfo(path);
    QString fileName = fileInfo.fileName();
    fileName.chop(fileInfo.completeSuffix().length() + 1);
    emit tabRename(activeProjectIndex, fileName);
}

bool MainPresenter::isProjectSaved(int projectIndex) {
    return !projectFiles[projectIndex]->path.isNull() &&
               !projectFiles[projectIndex]->path.isEmpty();
}

bool MainPresenter::projectHasUnsavedChanges(int projectIndex) {
    return projectFiles[projectIndex]->isDirty();
}

// The patch logic below assumes that only one operation
// will happen at once. If two separate model items
// initiate patch builds at the same time, they will be
// grouped together and possibly malformed in some cases.

void MainPresenter::initializeNewPatchIfNeeded() {
    if (isPatchInProgress) {
        return;
    }

    isInInitialState = false;
    isPatchInProgress = true;

    historyPointers[activeProjectIndex]++;

    if (historyPointers[activeProjectIndex] != projectHistories[activeProjectIndex].length()) {
        for (int i = projectHistories[activeProjectIndex].length() - 1; i >= historyPointers[activeProjectIndex]; i--) {
            projectHistories[activeProjectIndex][i]->~Patch();
            projectHistories[activeProjectIndex].pop_back();
        }
    }

    projectHistories[activeProjectIndex].append(
        new Patch(this, projects[activeProjectIndex], projectFiles[activeProjectIndex]->document)
    );
}

void MainPresenter::patchAdd(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    Value copiedValue(value, projectFiles[activeProjectIndex]->document.GetAllocator());
    patch.patchAdd("/" + path, copiedValue);
}

void MainPresenter::patchRemove(QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    patch.patchRemove("/" + path);
}

void MainPresenter::patchReplace(QString path, rapidjson::Value& value) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    Value copiedValue(value, projectFiles[activeProjectIndex]->document.GetAllocator());
    patch.patchReplace("/" + path, copiedValue);
}

void MainPresenter::patchCopy(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    patch.patchCopy("/" + from, "/" + path);
}

void MainPresenter::patchMove(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    patch.patchMove("/" + from, "/" + path);
}

void MainPresenter::sendPatch() {
    if (!isPatchInProgress) {
        throw "sendPatch() was called, but there was nothing to send.";
    }
    Patch& patch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    patch.apply();
    engines[activeProjectIndex]->sendPatchList(patch.getPatch());
    isPatchInProgress = false;
    projectFiles[activeProjectIndex]->markDirty();
}

void MainPresenter::liveUpdate(uint64_t controlId, float value) {
    engines[activeProjectIndex]->sendLiveControlUpdate(controlId, value);
}

void MainPresenter::undo() {
    if (historyPointers[activeProjectIndex] <= -1)
        return;

    Patch& undoPatch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    undoPatch.applyUndo();
    Value& undoPatchVal = undoPatch.getUndoPatch();
    engines[activeProjectIndex]->sendPatchList(undoPatchVal);

    historyPointers[activeProjectIndex]--;
}

void MainPresenter::redo() {
    if (historyPointers[activeProjectIndex] >= projectHistories[activeProjectIndex].length() - 1)
        return;

    historyPointers[activeProjectIndex]++;

    Patch& redoPatch = *projectHistories[activeProjectIndex][historyPointers[activeProjectIndex]];
    redoPatch.apply();
    engines[activeProjectIndex]->sendPatchList(redoPatch.getPatch());
}

void MainPresenter::switchActiveProject(int index) {
    if (isActiveProjectValid)
        disconnectUiUpdateSignals(projects[activeProjectIndex]);
    activeProjectIndex = index;
    connectUiUpdateSignals(projects[activeProjectIndex]);
    updateAll();
    isActiveProjectValid = true;
}

int MainPresenter::getNumOpenProjects() {
    return projects.count();
}

void MainPresenter::closeProject(int index) {
    removeProjectAt(index);
}

void MainPresenter::openSaveDialog() {
    emit saveDialogRequest();
}

void MainPresenter::notifySaveCancelled() {
    emit saveCancelled();
}

void MainPresenter::notifySaveCompleted() {
    emit saveCompleted();
}




//****************************//
// Control-specific functions //
//****************************//

void MainPresenter::updateAll() {
    emit masterPitchChanged(getMasterPitch());
    emit beatsPerMinuteChanged(getBeatsPerMinute());
}

int MainPresenter::getMasterPitch() {
    return static_cast<int>(std::round(projects[activeProjectIndex]->transport->masterPitch->get()));
}

void MainPresenter::setMasterPitch(int pitch, bool isFinal) {
    projects[activeProjectIndex]->transport->masterPitch->set(static_cast<float>(pitch), isFinal);
}

float MainPresenter::getBeatsPerMinute() {
    return projects[activeProjectIndex]->transport->beatsPerMinute->get();
}

void MainPresenter::setBeatsPerMinute(float bpm, bool isFinal) {
    projects[activeProjectIndex]->transport->beatsPerMinute->set(bpm, isFinal);
}
