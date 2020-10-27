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

#ifndef MAINPRESENTER_H
#define MAINPRESENTER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QJsonValue>
#include <QJsonObject>

#include "Model/project.h"
#include "Utilities/projectfile.h"
#include "Utilities/idgenerator.h"
#include "Core/communicator.h"
#include "Core/engine.h"
#include "Utilities/patch.h"
#include "patternpresenter.h"

class MainPresenter : public Communicator {
    Q_OBJECT
private:
    /// If there isn't an active (non-sent) patch in
    /// the list, add one.
    void initializeNewPatchIfNeeded();

    /// Used to track whether the user has 1) opened a
    /// project or 2) modified the blank project since
    /// the software was launched. This determines
    /// whether "File -> Open project" should replace
    /// the current tab or use a new one.
    bool isInInitialState;

    bool isActiveProjectValid;

    /// List of currently open projects
    QVector<Project*> projects;

    /// List of project files (mirrors list of projects)
    QVector<ProjectFile*> projectFiles;

    /// Handles engine lifecycle and communication.
    QVector<Engine*> engines;

    /// Patch that is currently being built. Deleted when sent.
    Patch* patchInProgress;

    /// API for the pattern editor
    PatternPresenter* patternPresenter;

    IdGenerator* id;

public:
    explicit MainPresenter(QObject* parent, IdGenerator* id);

    // Implementations of virtual functions in Communicator
    void patchAdd(QString path, QJsonValue& value);
    void patchRemove(QString path);
    void patchReplace(QString path, QJsonValue& newValue);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();

    void liveUpdate(quint64 controlId, float value);

    /// Project that is currently loaded
    int activeProjectIndex;

    // Used to access and manipulate project data
    void addProject(
        Project* project,
        ProjectFile* projectFile,
        Engine* engine
    );
    void removeProjectAt(int index);
    Project* getProjectAt(int index);
    ProjectFile* getProjectFileAt(int index);
    Engine* getEngineAt(int index);

signals:
    void tabAdd(QString name);
    void tabRename(int index, QString name);
    void tabSelect(int index);
    void tabRemove(int index);

    void flush();

    /// Emitted when a status message should be displayed
    void statusMessageRequest(QString message);

public slots:
    QString createID();
    PatternPresenter* getPatternPresenter();

    void newProject();
    QString loadProject(QString path);
    void saveActiveProject();
    void saveActiveProjectAs(QString path);

    /// Checks if the given project has ever been saved,
    /// or was opened from a file
    bool isProjectSaved(int projectIndex);

    /// Checks if the given project has unsaved changes
    bool projectHasUnsavedChanges(int projectIndex);

    int getNumOpenProjects();

    void switchActiveProject(int index);
    /// Does not update the active project
    void closeProject(int index);

    /// Tells the UI to display the given string as a
    /// status message.
    void displayStatusMessage(QString message);


    // Getters and setters for model properties
    float getBeatsPerMinute();
    void setBeatsPerMinute(float bpm, bool isFinal);
    quint8 getTimeSignatureNumerator();
    void setTimeSignatureNumerator(quint8 numerator);
    quint8 getTimeSignatureDenominator();
    void setTimeSignatureDenominator(quint8 denominator);
};

#endif // MAINPRESENTER_H
