#ifndef MAINPRESENTER_H
#define MAINPRESENTER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QSharedPointer>

#include "Include/rapidjson/document.h"

#include "Model/project.h"
#include "Utilities/projectfile.h"
#include "Utilities/idgenerator.h"
#include "Core/communicator.h"
#include "Core/engine.h"

class MainPresenter : public Communicator
{
    Q_OBJECT
private:
    void updateAll();

    /// Used to track whether the user has 1) opened a project or
    /// 2) modified the blank project since the software was
    /// launched. This determines whether "File -> Open project"
    /// should replace the current tab or use a new one.
    bool isInInitialState;

    IdGenerator* id;

    /// Handles engine lifecycle and communication.
    Engine* engine;

public:
    explicit MainPresenter(QObject *parent, IdGenerator* id);

     void patch(QString operation, QString from, QString path, rapidjson::Value& value);

    // List of currently open projects
    QVector<QSharedPointer<Project>> projects;

    // List of project files (mirrors list of projects)
    QVector<QSharedPointer<ProjectFile>> projectFiles;

    // Project that is currently loaded
    QSharedPointer<Project> activeProject;
    int activeProjectIndex;

signals:
    void masterPitchChanged(int pitch);

public slots:
    void loadProject(QString path);
    void saveActiveProject();

    int getMasterPitch();
    void setMasterPitch(int pitch, bool isFinal);
};

#endif // MAINPRESENTER_H
