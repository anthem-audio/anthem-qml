#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project, plus metadata

#include <QString>
#include <QObject>

#include "Include/rapidjson/document.h"

class ProjectFile : QObject {
Q_OBJECT
public:
    // Empty project file
    ProjectFile(QObject* parent);
    ProjectFile(QObject* parent, QString path);
    rapidjson::Document document;
    QString path;

    void save();
};

#endif // DOCUMENTWRAPPER_H
