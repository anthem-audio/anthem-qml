/*
    Copyright (C) 2019, 2020 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

#include "mainpresenter.h"

#include "Include/rapidjson/document.h"
#include "Utilities/exceptions.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <math.h>

using namespace rapidjson;

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id)
                                : Communicator(parent) {
    isPatchInProgress = false;
    isActiveProjectValid = true;
    isInInitialState = true;

    this->id = id;

    // Initialize with blank project
    auto projectFile = new ProjectFile(this);
    auto projectModel = new Project(this, id);
    activeProjectIndex = 0;

    // Connect change signals from the model to the UI
    connectUiUpdateSignals(projectModel);

    // Initialize child presenters
    patternPresenter = new PatternPresenter(this, id, projectModel);

    // Start the engine
    auto engine = new Engine(dynamic_cast<QObject*>(this));
    engine->start();

    addProject(projectModel, projectFile, engine);
}

PatternPresenter* MainPresenter::getPatternPresenter() {
    return this->patternPresenter;
}

void MainPresenter::addProject(Project* project, ProjectFile* projectFile,
                               Engine* engine) {
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

QVector<Patch*> MainPresenter::getProjectHistoryAt(
    int index
) {
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

    // If the active project is closed, the index will
    // be set to -1.
    if (index == activeProjectIndex) {
        isActiveProjectValid = false;
        activeProjectIndex = -1;
    }
    // This prevents the active project index from
    // becoming desynced in cases where the active
    // projct is positioned after the tab that was
    // closed.
    else if (index < activeProjectIndex) {
        activeProjectIndex--;
    }
}

void MainPresenter::newProject() {
    auto projectFile = new ProjectFile(this);
    auto projectModel = new Project(this, id);
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
        emit informationDialogRequest(
            "Error", "That project does not exist."
        );
        return;
    }

    // Ensure the file ends with ".anthem"
    if (fileInfo.suffix() != "anthem") {
        emit informationDialogRequest(
            "Error",
            "That is not a *.anthem file. "
            "If you think the file you chose is valid, "
            "please rename it so it has a \".anthem\" extension."
        );
        return;
    }

    ProjectFile* projectFile;

    try {
        projectFile = new ProjectFile(this, path);
    }
    catch (const InvalidProjectException& ex) {
        emit informationDialogRequest(
            "Error", QString(ex.what())
        );
        return;
    }

    QString fileName = fileInfo.fileName();
    fileName.chop(fileInfo.completeSuffix().length() + 1);

    if (isInInitialState) {
        removeProjectAt(0);
    }

    if (projectFile->document.IsNull()) {
        // This should never trip and will be removed in a future PR.
        emit informationDialogRequest(
            "Error", "Something is very wrong."
        );
        projectFile->~ProjectFile();
        return;
    }

    Project* project;

    try {
        // Initialize model with JSON
        project = new Project(
            this, id, projectFile->document["project"]
        );
    }
    catch (const InvalidProjectException& ex) {
        QString errorText =
            "The project file failed to load. ";
        emit informationDialogRequest(
            "Error", errorText.append(ex.what())
        );
        projectFile->~ProjectFile();
        return;
    }

    // Create and start new engine
    // TODO: Once engines can be stared and stopped by
    //   the user, don't start immediately. (?)
    // TODO: Engine may have errors when starting.
    //   Report these to the user.
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
    projectFiles[
        activeProjectIndex
    ]->save(
        *projects[activeProjectIndex]
    );
}

void MainPresenter::saveActiveProjectAs(QString path) {
    projectFiles[
        activeProjectIndex
    ]->saveAs(
        *projects[activeProjectIndex], path
    );

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

    if (historyPointers[activeProjectIndex] !=
            projectHistories[activeProjectIndex].length()) {
        for (
            int i = projectHistories[
                        activeProjectIndex
                    ].length() - 1;
            i >= historyPointers[activeProjectIndex];
            i--
        ) {
            projectHistories[activeProjectIndex][i]->~Patch();
            projectHistories[activeProjectIndex].pop_back();
        }
    }

    projectHistories[activeProjectIndex].append(
        new Patch(this, projects[activeProjectIndex])
    );
}

void MainPresenter::patchAdd(
    QString path, rapidjson::Value& value
) {
    initializeNewPatchIfNeeded();

    Patch& patch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];

    Value copiedValue(value, *patch.getPatchAllocator());
    patch.patchAdd("/" + path, copiedValue);
}

void MainPresenter::patchRemove(
    QString path, rapidjson::Value& oldValue
) {
    initializeNewPatchIfNeeded();

    Patch& patch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];

    Value copiedValue(
        oldValue, *patch.getUndoPatchAllocator()
    );
    patch.patchRemove("/" + path, copiedValue);
}

void MainPresenter::patchReplace(
    QString path,
    rapidjson::Value& oldValue,
    rapidjson::Value& newValue
) {
    initializeNewPatchIfNeeded();

    Patch& patch
        = *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];

    Value copiedOldValue(
        oldValue, *patch.getUndoPatchAllocator()
    );
    Value copiedNewValue(
        newValue, *patch.getPatchAllocator()
    );
    patch.patchReplace(
        "/" + path, copiedOldValue, copiedNewValue
    );
}

void MainPresenter::patchCopy(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];
    patch.patchCopy("/" + from, "/" + path);
}

void MainPresenter::patchMove(QString from, QString path) {
    initializeNewPatchIfNeeded();
    Patch& patch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];
    patch.patchMove("/" + from, "/" + path);
}

void MainPresenter::sendPatch() {
    if (!isPatchInProgress) {
        throw "sendPatch() was called, but there was nothing to send.";
    }
    Patch& patch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];
    patch.apply();

    engines[
        activeProjectIndex
    ]->sendPatchList(patch.getPatch());

    isPatchInProgress = false;
    projectFiles[activeProjectIndex]->markDirty();
}

void MainPresenter::liveUpdate(
    uint64_t controlId, float value
) {
    engines[
        activeProjectIndex
    ]->sendLiveControlUpdate(controlId, value);
}

Document::AllocatorType& MainPresenter::getPatchAllocator() {
    initializeNewPatchIfNeeded();
    return *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ]->getPatchAllocator();
}

void MainPresenter::undo() {
    if (historyPointers[activeProjectIndex] <= -1)
        return;

    Patch& undoPatch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];

    undoPatch.applyUndo();
    Value& undoPatchVal = undoPatch.getUndoPatch();
    engines[
        activeProjectIndex
    ]->sendPatchList(undoPatchVal);

    historyPointers[activeProjectIndex]--;
}

void MainPresenter::redo() {
    if (
        historyPointers[activeProjectIndex] >=
            projectHistories[activeProjectIndex].length() - 1
    ) {
        return;
    }

    historyPointers[activeProjectIndex]++;

    Patch& redoPatch =
        *projectHistories[
            activeProjectIndex
        ][
            historyPointers[activeProjectIndex]
        ];

    redoPatch.apply();
    engines[
        activeProjectIndex
    ]->sendPatchList(redoPatch.getPatch());
}

void MainPresenter::switchActiveProject(int index) {
    if (isActiveProjectValid) {
        disconnectUiUpdateSignals(
            projects[activeProjectIndex]
        );
    }

    activeProjectIndex = index;

    connectUiUpdateSignals(projects[activeProjectIndex]);
    emitAllChangeSignals();

    // Update child presenters
    patternPresenter->setActiveProject(
        projects[activeProjectIndex]
    );

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

void MainPresenter::displayStatusMessage(QString message) {
    emit statusMessageRequest(message);
}



//****************************//
// Control-specific functions //
//****************************//

void MainPresenter::emitAllChangeSignals() {
    emit masterPitchChanged(getMasterPitch());
    emit beatsPerMinuteChanged(getBeatsPerMinute());
    emit timeSignatureNumeratorChanged(getTimeSignatureNumerator());
    emit timeSignatureDenominatorChanged(getTimeSignatureDenominator());
}

void MainPresenter::connectUiUpdateSignals(Project* project) {
    QObject::connect(project->getTransport()->masterPitch,    SIGNAL(displayValueChanged(float)),
                     this,                                    SLOT(ui_updateMasterPitch(float)));
    QObject::connect(project->getTransport()->beatsPerMinute, SIGNAL(displayValueChanged(float)),
                     this,                                    SLOT(ui_updateBeatsPerMinute(float)));
    QObject::connect(project->getTransport(),                 SIGNAL(numeratorDisplayValueChanged(quint8)),
                     this,                                    SLOT(ui_updateTimeSignatureNumerator(quint8)));
    QObject::connect(project->getTransport(),                 SIGNAL(denominatorDisplayValueChanged(quint8)),
                     this,                                    SLOT(ui_updateTimeSignatureDenominator(quint8)));
}

// This should mirror the function above
void MainPresenter::disconnectUiUpdateSignals(Project* project) {
    QObject::disconnect(project->getTransport()->masterPitch,    SIGNAL(displayValueChanged(float)),
                        this,                                    SLOT(ui_updateMasterPitch(float)));
    QObject::disconnect(project->getTransport()->beatsPerMinute, SIGNAL(displayValueChanged(float)),
                        this,                                    SLOT(ui_updateBeatsPerMinute(float)));
    QObject::disconnect(project->getTransport(),                 SIGNAL(numeratorDisplayValueChanged(quint8)),
                        this,                                    SLOT(ui_updateTimeSignatureNumerator(quint8)));
    QObject::disconnect(project->getTransport(),                 SIGNAL(denominatorDisplayValueChanged(quint8)),
                        this,                                    SLOT(ui_updateTimeSignatureDenominator(quint8)));
}



int MainPresenter::getMasterPitch() {
    return static_cast<int>(
        std::round(
            projects[
                activeProjectIndex
            ]->getTransport()->masterPitch->get()
        )
    );
}

void MainPresenter::setMasterPitch(int pitch, bool isFinal) {
    projects[
        activeProjectIndex
    ]->getTransport()->masterPitch->set(
        static_cast<float>(pitch), isFinal
    );
}

void MainPresenter::ui_updateMasterPitch(float pitch) {
    emit masterPitchChanged(
        static_cast<int>(std::round(pitch))
    );
}


float MainPresenter::getBeatsPerMinute() {
    return projects[
        activeProjectIndex
    ]->getTransport()->beatsPerMinute->get();
}

void MainPresenter::setBeatsPerMinute(float bpm, bool isFinal) {
    projects[
        activeProjectIndex
    ]->getTransport()->beatsPerMinute->set(bpm, isFinal);
}

void MainPresenter::ui_updateBeatsPerMinute(float bpm) {
    emit beatsPerMinuteChanged(bpm);
}


quint8 MainPresenter::getTimeSignatureNumerator() {
    return projects[
        activeProjectIndex
    ]->getTransport()->getNumerator();
}

void MainPresenter::setTimeSignatureNumerator(quint8 numerator) {
    projects[
        activeProjectIndex
    ]->getTransport()->setNumerator(numerator);
}

void MainPresenter::ui_updateTimeSignatureNumerator(quint8 numerator) {
    emit timeSignatureNumeratorChanged(numerator);
}


quint8 MainPresenter::getTimeSignatureDenominator() {
    return projects[
        activeProjectIndex
    ]->getTransport()->getDenominator();
}

void MainPresenter::setTimeSignatureDenominator(quint8 denominator) {
    projects[
        activeProjectIndex
    ]->getTransport()->setDenominator(denominator);
}

void MainPresenter::ui_updateTimeSignatureDenominator(quint8 denominator) {
    emit timeSignatureDenominatorChanged(denominator);
}
