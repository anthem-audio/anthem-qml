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

#include "Include/rapidjson/filereadstream.h"
#include "Include/rapidjson/filewritestream.h"
#include "Include/rapidjson/writer.h"
#include "Include/rapidjson/schema.h"

using namespace rapidjson;

ProjectFile::ProjectFile(QObject* parent) : QObject(parent) {
    dirty = false;
    document.SetObject();
}

ProjectFile::ProjectFile(
    QObject* parent, QString path
) : QObject(parent) {
    // Below are JSON schemas (https://json-schema.org/) for validating project files. Use another editor to modify them.
    auto schema_0_0_1 = R"(
        {"$schema":"http://json-schema.org/draft-04/schema#","type":"object","properties":{"software_version":{"type":"string","pattern":"0.0.1"},"project":{"$ref":"#/definitions/Project"}},"required":["software_version","project"],"title":"The Root Schema","definitions":{"Project":{"type":"object","properties":{"song":{"type":"object","properties":{"patterns":{"type":"array"},"arrangements":{"type":"array"}}},"transport":{"$ref":"#/definitions/Transport"},"mixer":{"type":"object"},"generators":{"type":"array"}},"required":["transport"]},"Transport":{"type":"object","properties":{"master_pitch":{"$ref":"#/definitions/Control"},"beats_per_minute":{"$ref":"#/definitions/Control"},"default_numerator":{"type":"number","minimum":1,"maximum":16},"default_denominator":{"type":"number","enum":[1,2,4,8,16]}},"required":["master_pitch","beats_per_minute","default_numerator","default_denominator"]},"Control":{"type":"object","properties":{"id":{"type":"number"},"initial_value":{"type":"number"},"minimum":{"type":"number"},"maximum":{"type":"number"},"step":{"type":"number"},"connection":{"type":"null"},"override_automation":{"type":"boolean"}},"required":["id","initial_value","minimum","maximum","step","connection","override_automation"]}}}
    )";


    dirty = false;
    this->path = path;


    // Attempt to load the file as JSON

    bool isWindows = QSysInfo::kernelType() == "winnt";

    FILE* fp = std::fopen(
        path.toUtf8(), isWindows ? "rb" : "r"
    );

    char readBuffer[65536];
    FileReadStream stream(
        fp, readBuffer, sizeof(readBuffer)
    );

    document.ParseStream(stream);


    // Check for invalid JSON

    if (document.HasParseError()) {
        fclose(fp);
        throw InvalidProjectException(
            "This project is corrupted and could not be opened."
        );
    }

    const char* schemaForValidation;


    // Check if software version in project matches current
    // software version

    if (document.HasMember("software_version")) {
        QString version =
            document["software_version"].GetString();
        // Current version
        if (version == "0.0.1") {
            schemaForValidation = schema_0_0_1;
        }
        // Newer or unrecognized version
        else {
            fclose(fp);
            auto error =
                "This project was made with a newer version "
                "of Anthem (" + version.toStdString() + ") "
                "and could not be opened.";
            throw InvalidProjectException(error.c_str());
        }
    }
    else {
        fclose(fp);
        throw InvalidProjectException(
            "This project is corrupted and could not be opened."
        );
    }


    // Validate project JSON against schema

    Document sd;
    sd.Parse(schemaForValidation);
    if (sd.HasParseError()) {
        fclose(fp);
        throw InvalidProjectException(
            "Schema is invalid. This is a bug; please report "
            "it on Github."
        );
    }
    SchemaDocument schema(sd);

    // TODO: user-friendly but still informative error message
    SchemaValidator validator(schema);
    if (!document.Accept(validator)) {
        // Input JSON is invalid according to the schema
        // Output diagnostic information
        StringBuffer sb;
        validator
            .GetInvalidSchemaPointer()
            .StringifyUriFragment(sb);
        QString err =
            "This project is corrupted and could "
            "not be loaded.";
        // For debugging:
        /*
        err += "\n";
        err += "Invalid schema: ";
        err += sb.GetString();
        err += "\n";
        err += "Invalid keyword: ";
        err += validator.GetInvalidSchemaKeyword();
        err += "\n";
        sb.Clear();
        validator.GetInvalidDocumentPointer().StringifyUriFragment(sb);
        err += "Invalid document: ";
        err += sb.GetString();
        err += "\n";
        */
        throw InvalidProjectException(err.toUtf8());
    }

    fclose(fp);
}

void ProjectFile::save(Project& project) {
    Document doc;
    doc.SetObject();
    Value versionVal("0.0.1");
    doc.AddMember(
        "software_version", versionVal, doc.GetAllocator()
    );

    Value projectVal(kObjectType);
    project.serialize(projectVal, doc);
    doc.AddMember(
        "project", projectVal, doc.GetAllocator()
    );

    bool isWindows = QSysInfo::kernelType() == "winnt";
    FILE* fp =
        std::fopen(
            (path).toUtf8(), isWindows ? "wb" : "w"
        );
    char writeBuffer[65536];
    FileWriteStream stream(
        fp, writeBuffer, sizeof(writeBuffer)
    );
    Writer<FileWriteStream> writer(stream);
    doc.Accept(writer);
    fclose(fp);

    document.CopyFrom(doc, document.GetAllocator());
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
