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

#include "projectfile.h"
#include "exceptions.h"

#include <QFile>
#include <QByteArray>
#include <QJsonDocument>

ProjectFile::ProjectFile(QObject* parent) : QObject(parent) {
    this->dirty = false;
}

ProjectFile::ProjectFile(
    QObject* parent, QString path
) : QObject(parent) {
    dirty = false;
    this->path = path;

    // Attempt to load the file as JSON

    bool isWindows = QSysInfo::kernelType() == "winnt";

    QFile loadFile(path);
    if (!loadFile.open(QIODevice::ReadOnly)) {
        // TODO: error!
        throw;
    }

    QByteArray data = loadFile.readAll();

    QJsonParseError err;
    QJsonDocument loadDoc(QJsonDocument::fromJson(data, &err));

    // Check for invalid JSON

    // TODO: more specific errors
    if (err.error != QJsonParseError::NoError) {
        throw InvalidProjectException(
            "This project is corrupted and could not be opened."
        );
    }

    // Check if software version in project matches current
    // software version

    this->json = loadDoc.object();

    if (!json["software_version"].isUndefined()) {
        QString version = json["software_version"].toString();
        // Current version
        if (version == "0.0.1") {
//            schemaForValidation = schema_0_0_1;
        }
        // Newer or unrecognized version
        else {
            auto error =
                "This project was made with a newer version "
                "of Anthem (" + version.toStdString() + ") "
                "and could not be opened.";
            throw InvalidProjectException(error.c_str());
        }
    }
    else {
        throw InvalidProjectException(
            "This project is corrupted and could not be opened."
        );
    }
}

void ProjectFile::save(Project& project) {
    QJsonObject root;
    root["software_version"] = "0.0.1";

    QJsonObject projectVal;
    project.serialize(projectVal);
    root["project"] = projectVal;

    QJsonDocument doc(root);

    QFile saveFile(this->path);

    if (!saveFile.open(QFile::OpenModeFlag::WriteOnly)) {
        // TODO: better error!
        throw;
    }
    saveFile.write(doc.toJson());

    markClean();
}

void ProjectFile::saveAs(Project& project, QString path) {
    this->path = path;
    save(project);
}

void ProjectFile::markDirty() {
    dirty = true;
}

void ProjectFile::markClean() {
    dirty = false;
}

bool ProjectFile::isDirty() {
    return dirty;
}
