#ifndef MAINPRESENTER_H
#define MAINPRESENTER_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QSharedPointer>

#include "../Include/rapidjson/include/rapidjson/document.h"

#include "../Model/project.h"
#include "../Utilities/projectfile.h"

class MainPresenter : public QObject
{
    Q_OBJECT
private:
    void updateAll();
public:
    explicit MainPresenter(QObject *parent = nullptr);

    // List of currently open projects
    QVector<QSharedPointer<Project>> projects;

    // List of project files (mirrors list of projects)
    QVector<QSharedPointer<ProjectFile>> projectFiles;

    // Project that is currently loaded
    QSharedPointer<Project> activeProject;

signals:
    void masterPitchChanged(int pitch);

public slots:
    void loadProject(QString path);

    int getMasterPitch();
    void setMasterPitch(int pitch);
};

#endif // MAINPRESENTER_H
