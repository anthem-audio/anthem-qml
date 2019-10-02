#ifndef MAINPRESENTER_H
#define MAINPRESENTER_H

#include <QObject>
#include <QString>
#include <QVector>

#include "Include/rapidjson/document.h"

#include "Model/project.h"
#include "Utilities/projectfile.h"
#include "Utilities/idgenerator.h"
#include "Core/communicator.h"
#include "Core/engine.h"
#include "Utilities/patch.h"

class MainPresenter : public Communicator {
    Q_OBJECT
private:
    void updateAll();

    void connectUiUpdateSignals(Project* project);
    void disconnectUiUpdateSignals(Project* project);

    /// If there isn't an active (non-sent) patch in the list, add one
    void initializeNewPatchIfNeeded();

    /// Used to track whether the user has 1) opened a project or
    /// 2) modified the blank project since the software was
    /// launched. This determines whether "File -> Open project"
    /// should replace the current tab or use a new one.
    bool isInInitialState;

    bool isActiveProjectValid;

    /// List of currently open projects
    QVector<Project*> projects;

    /// List of project files (mirrors list of projects)
    QVector<ProjectFile*> projectFiles;

    /// Handles engine lifecycle and communication.
    QVector<Engine*> engines;

    /// Current place in the history
    QVector<int> historyPointers;

    /// List of project histories
    QVector<QVector<Patch*>> projectHistories;
    bool isPatchInProgress;

    IdGenerator* id;

public:
    explicit MainPresenter(QObject *parent, IdGenerator* id);

    // These are virtual functions in Communicator
    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();

    void liveUpdate(uint64_t controlId, float value);

    /// Project that is currently loaded
    int activeProjectIndex;

    // Used to access and manipulate project data
    void addProject(Project* project, ProjectFile* projectFile, Engine* engine);
    Project* getProjectAt(int index);
    ProjectFile* getProjectFileAt(int index);
    Engine* getEngineAt(int index);
    QVector<Patch*> getProjectHistoryAt(int index);
    int getHistoryPointerAt(int index);
    void removeProjectAt(int index);

signals:
    void masterPitchChanged(int pitch);
    void tabAdd(QString name);
    void tabRename(int index, QString name);
    void tabSelect(int index);
    void tabRemove(int index);

public slots:
    void newProject();
    void loadProject(QString path);
    void saveActiveProject();
    void saveActiveProjectAs(QString path);

    // Getters and setters for model properties
    int getMasterPitch();
    void setMasterPitch(int pitch, bool isFinal);

    bool isActiveProjectSaved();

    // Functions with the ui_ prefix are used as receiver slots
    // for model change signals. Each ui_ function should:
    //     a) always be connected to the relevant model's update
    //        signals, and
    //     b) emit the relevant update signal.
    void ui_updateMasterPitch(float pitch);

    void undo();
    void redo();

    // These functions do not update the tab state in the UI
    void switchActiveProject(int index);
    /// Does not update the active project
    void closeProject(int index);
};

#endif // MAINPRESENTER_H
