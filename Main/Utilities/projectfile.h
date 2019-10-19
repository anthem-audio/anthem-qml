#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project, plus metadata

#include <QString>
#include <QObject>

#include "Include/rapidjson/document.h"

class ProjectFile : QObject {
Q_OBJECT
private:
    bool dirty;
public:
    // Empty project file
    ProjectFile(QObject* parent);

    // Project from path
    ProjectFile(QObject* parent, QString path);

    rapidjson::Document document;
    QString path;

    void markDirty();
    void markClean();
    bool isDirty();

    void save();
    void saveAs(QString path);
};

#endif // DOCUMENTWRAPPER_H
