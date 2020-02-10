/*
    Copyright (C) 2020 Joshua Wade

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

#include "song.h"

using namespace rapidjson;

Song::Song(ModelItem* parent, IdGenerator* id) : ModelItem(parent, "song") {
    this->id = id;
    this->patterns = QHash<QString, Pattern*>();
}

Song::Song(ModelItem* parent, IdGenerator* id, Value& songValue)
            : ModelItem(parent, "song") {
    this->id = id;
    Value& patternMap = songValue["patterns"];
    for (auto& pair : patternMap.GetObject()) {
        QString patternId(pair.name.GetString());
        this->patterns[patternId] = new Pattern(this, id, pair.value);
    }
}

void Song::onPatchReceived(QStringRef pointer, PatchFragment& patch) {
    QString patternsStr = "/patterns";

    if (pointer.startsWith(patternsStr)) {
        // If it starts with "/patterns", it's assumed to
        // be in this form:
        //     /patterns/(u64 ID)

        // Pointer starting with /(u64 ID)
        QStringRef pointerWithoutPatterns = pointer.mid(patternsStr.length());

        // Index of second slash in the above pointer, if it exists
        int secondSlashIndex = pointerWithoutPatterns.indexOf("/", 1);

        int patternPtrStart = secondSlashIndex < 0
                                    ? pointerWithoutPatterns.length()
                                    : secondSlashIndex;

        QString key = pointerWithoutPatterns.mid(1, patternPtrStart).toString();

        // If there was a second slash, that means this patch is describing an
        // operation inside one of the patterns, so we'll pass it on.
        if (secondSlashIndex >= 0) {
            patterns[key]->onPatchReceived(
                    pointerWithoutPatterns.mid(patternPtrStart),
                    patch);
        }
        // Otherwise, this is an add, delete, or copy operation and should be
        // handled here.
        else {
            if (patch.getType() == PatchFragment::ADD) {
                patterns[key] = new Pattern(this, id, patch.patch["value"]);
                emit patternAdd(key);
            }
            else if (patch.getType() == PatchFragment::REMOVE) {
                emit patternRemove(key);
                delete patterns[key];
                patterns.remove(key);
            }
            else if (patch.getType() == PatchFragment::COPY) {

            }
            else {
                throw "song.cpp onPatchReceived(): Unsupported patch operation.";
            }
        }
    }
    else {
        throw "song.cpp onPatchReceived(): Unsupported patch operation.";
    }
}

void Song::serialize(Value& value, Document::AllocatorType& allocator) {
    value.SetObject();

    Value patterns(kObjectType);
    auto keys = this->patterns.keys();
    for (QString key : keys) {
        Value v(kObjectType);
        this->patterns[key]->serialize(v, allocator);

        // https://stackoverflow.com/a/33473321/8166701
        auto indexStr = key.toStdString();

        Value index(indexStr.c_str(), static_cast<SizeType>(indexStr.size()),
                    allocator);

        patterns.AddMember(index, v, allocator);
    }

    value.AddMember("patterns", patterns, allocator);
}

void Song::addPattern(QString name, QColor color) {
    QString patternID = QString::number(id->get());


    Value patchVal(kObjectType);


    Value nameVal;
    setStr(nameVal, name, getPatchAllocator());

    Value colorVal;
    setStr(colorVal, color.name(), getPatchAllocator());


    patchVal.AddMember("display_name", nameVal, getPatchAllocator());
    patchVal.AddMember("color", colorVal, getPatchAllocator());

    patchAdd("patterns/" + patternID, patchVal);


    patterns[patternID] = new Pattern(this, id, name, color);

    sendPatch();

    emit patternAdd(patternID);
}

void Song::removePattern(QString id) {
    Value currentPatternValue;
    patterns[id]->serialize(currentPatternValue, getPatchAllocator());
    patchRemove("patterns/" + id, currentPatternValue);

    delete patterns[id];
    patterns.remove(id);

    emit patternRemove(id);
}

const QHash<QString, Pattern*>& Song::getPatterns() {
    return this->patterns;
}

Pattern* Song::getPattern(QString key) {
    return this->patterns[key];
}
