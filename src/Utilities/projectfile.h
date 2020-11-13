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

#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// Class for storing the JSON model of the project,
// plus metadata

#include <QString>
#include <QObject>
#include <QJsonObject>

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
    /// Only updated on save.
    QJsonObject json;
    QString path;

    void markDirty();
    void markClean();
    bool isDirty();

    void save(Project& project);
    void saveAs(Project& project, QString path);
};

#endif // DOCUMENTWRAPPER_H
