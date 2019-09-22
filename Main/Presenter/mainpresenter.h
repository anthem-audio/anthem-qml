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

class MainPresenter : public Communicator
{
    Q_OBJECT
private:
    void updateAll();
    // TODO: disconnect UI signals when changing projects?
    void connectUiUpdateSignals(Project* project);

    /// If there isn't an active (non-sent) patch in the list, add one
    void initializeNewPatchIfNeeded();

    /// Used to track whether the user has 1) opened a project or
    /// 2) modified the blank project since the software was
    /// launched. This determines whether "File -> Open project"
    /// should replace the current tab or use a new one.
    bool isInInitialState;

    IdGenerator* id;

    /// Handles engine lifecycle and communication.
    Engine* engine;

    QVector<Patch*> projectHistory;
    bool isPatchInProgress;

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

    /// List of currently open projects
    QVector<Project*> projects;

    /// List of project files (mirrors list of projects)
    QVector<ProjectFile*> projectFiles;

    /// Project that is currently loaded
    Project* activeProject;
    int activeProjectIndex;

    /// Current place in the history
    int historyPointer;

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

    int getMasterPitch();
    void setMasterPitch(int pitch, bool isFinal);

    void ui_updateMasterPitch(float pitch);

    void undo();
    void redo();
};

#endif // MAINPRESENTER_H
