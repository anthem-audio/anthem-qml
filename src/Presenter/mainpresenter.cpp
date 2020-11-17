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

#include "Utilities/exceptions.h"

#include <QFileInfo>
#include <QDir>
#include <QStringList>
#include <QSysInfo>

#include <math.h>

MainPresenter::MainPresenter(QObject *parent, IdGenerator* id)
                                : Communicator(parent) {
    patchInProgress = nullptr;
    isActiveProjectValid = true;
    isInInitialState = true;

    this->id = id;

    QString projectID = QString::number(id->get());

    // Initialize with blank project
    auto projectFile = new ProjectFile(this);
    auto project = new Project(this, id, projectID);
    activeProjectIndex = 0;

    // Initialize child presenters
    patternPresenter = new PatternPresenter(this, id, project);

    // Start the engine
    auto engine = new Engine(dynamic_cast<QObject*>(this));
    engine->start();

    addProject(project, projectFile, engine);
}

PatternPresenter* MainPresenter::getPatternPresenter() {
    return this->patternPresenter;
}

QString MainPresenter::createID() {
    return QString::number(this->id->get());
}

void MainPresenter::addProject(Project* project, ProjectFile* projectFile,
                               Engine* engine) {
    projects.append(project);
    projectFiles.append(projectFile);
    engines.append(engine);
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

void MainPresenter::removeProjectAt(int index) {
    QString key = projects[index]->getID();

    // Notify child presenters of the change before removing things
    if (activeProjectIndex == index) {
        patternPresenter->setActiveProject(nullptr);
    }

    delete projects[index];
    delete projectFiles[index];
    delete engines[index];

    projects.removeAt(index);
    projectFiles.removeAt(index);
    engines.removeAt(index);

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

    emit this->tabRemove(index, key);
}

QString MainPresenter::newProject() {
    QString projectID = QString::number(this->id->get());

    auto projectFile = new ProjectFile(this);
    auto project = new Project(this, id, projectID);
    auto engine = new Engine(this);
    engine->start();
    addProject(project, projectFile, engine);
    switchActiveProject(projects.length() - 1);

    QString id = project->getID();
    emit tabAdd("New project", id);
    emit tabSelect(activeProjectIndex, id);

    isInInitialState = false;
    return projectID;
}

QString MainPresenter::loadProject(QString path) {
    QFileInfo fileInfo(path);

    QString projectID = QString::number(this->id->get());

    // Check if the path exists and is a file
    if (!fileInfo.exists() || !fileInfo.isFile()) {
        return "That project does not exist.";
    }

    // Ensure the file ends with ".anthem"
    if (fileInfo.suffix() != "anthem") {
        return "That is not a *.anthem file. "
               "If you think the file you chose is valid, "
               "please rename it so it has a \".anthem\" extension.";
    }

    ProjectFile* projectFile;

    try {
        projectFile = new ProjectFile(this, path);
    }
    catch (const InvalidProjectException& ex) {
        return QString(ex.what());
    }

    QString fileName = fileInfo.fileName();
    fileName.chop(fileInfo.completeSuffix().length() + 1);

    Project* project;

    try {
        // Initialize model with JSON
        QJsonObject projectJson =
                projectFile->json["project"].toObject();

        project = new Project(this, id, projectID, projectJson);
    }
    catch (const InvalidProjectException& ex) {
        QString errorText =
            "The project file failed to load. ";
        delete projectFile;
        return errorText.append(ex.what());
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
        removeProjectAt(0);
    }

    QString id = project->getID();

    if (isInInitialState) {
        emit tabRename(0, fileName);
        emit tabSelect(0, id);
    }
    else {
        emit tabAdd(fileName, id);
        emit tabSelect(getNumOpenProjects() - 1, id);
    }

    isInInitialState = false;

    return projectID;
}

void MainPresenter::saveActiveProject() {
    projectFiles[activeProjectIndex]
            ->save(*projects[activeProjectIndex]);
}

void MainPresenter::saveActiveProjectAs(QString path) {
    projectFiles[activeProjectIndex]
            ->saveAs(*projects[activeProjectIndex], path);

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
    if (patchInProgress != nullptr) {
        return;
    }

    isInInitialState = false;

    patchInProgress = new Patch(this);
}

void MainPresenter::patchAdd(QString path, QJsonValue& value) {
    initializeNewPatchIfNeeded();
    patchInProgress->patchAdd("/" + path, value);
}

void MainPresenter::patchRemove(QString path) {
    initializeNewPatchIfNeeded();
    patchInProgress->patchRemove("/" + path);
}

void MainPresenter::patchReplace(
        QString path, QJsonValue& newValue) {
    initializeNewPatchIfNeeded();
    patchInProgress->patchReplace("/" + path, newValue);
}

void MainPresenter::patchCopy(QString from, QString path) {
    initializeNewPatchIfNeeded();
    patchInProgress->patchCopy("/" + from, "/" + path);
}

void MainPresenter::patchMove(QString from, QString path) {
    initializeNewPatchIfNeeded();
    patchInProgress->patchMove("/" + from, "/" + path);
}

void MainPresenter::sendPatch() {
    if (patchInProgress == nullptr) {
        throw "sendPatch() was called, but there was nothing to send.";
    }

    engines[
        activeProjectIndex
    ]->sendPatchList(patchInProgress->getPatch());

    delete patchInProgress;
    patchInProgress = nullptr;

    projectFiles[activeProjectIndex]->markDirty();
}

void MainPresenter::liveUpdate(
    quint64 controlId, float value
) {
    engines[
        activeProjectIndex
    ]->sendLiveControlUpdate(controlId, value);
}

void MainPresenter::switchActiveProject(int index) {
    activeProjectIndex = index;

    // Update child presenters
    patternPresenter->setActiveProject(
        projects[activeProjectIndex]
    );

    isActiveProjectValid = true;

    emit tabSelect(index, projects[activeProjectIndex]->getID());
}

int MainPresenter::getNumOpenProjects() {
    return projects.count();
}

int MainPresenter::getActiveProjectIndex() {
    return activeProjectIndex;
}

QString MainPresenter::getActiveProjectKey() {
    return projects[activeProjectIndex]->getID();
}

void MainPresenter::closeProject(int index) {
    removeProjectAt(index);
}

void MainPresenter::displayStatusMessage(QString message) {
    emit statusMessageRequest(message);
}



//****************************//
// Control-specific functions //
//****************************//


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
