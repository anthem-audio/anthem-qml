#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project, plus metadata

#include <QString>
#include <QObject>

#include "Include/rapidjson/document.h"
#include "Model/project.h"

class ProjectFile : QObject {
Q_OBJECT
private:
    bool dirty;
public:
    // Empty project file
    ProjectFile(QObject* parent);

    // Project from path
    ProjectFile(QObject* parent, QString path);

    /// In-memory JSON representation of the project.
    /// ONLY updated on save.
    rapidjson::Document document;
    QString path;

    void markDirty();
    void markClean();
    bool isDirty();

    void save(Project& project);
    void saveAs(Project& project, QString path);
};

#endif // DOCUMENTWRAPPER_H
