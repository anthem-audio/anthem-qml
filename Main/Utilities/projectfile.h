#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project, plus metadata

#include <QString>

#include "../Include/rapidjson/include/rapidjson/document.h"

class ProjectFile {
public:
    ProjectFile(QString path);
    rapidjson::Document document;
    QString path;
};

#endif // DOCUMENTWRAPPER_H
