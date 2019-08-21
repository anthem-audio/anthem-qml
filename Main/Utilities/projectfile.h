#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project, plus metadata

#include <QString>

#include "Include/rapidjson/include/rapidjson/document.h"

class ProjectFile {
public:
    // Empty project file
    ProjectFile();
    ProjectFile(QString path);
    rapidjson::Document document;
    QString path;

    void save();
};

#endif // DOCUMENTWRAPPER_H
