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
    patterns[QString::number(id->get())] = new Pattern(this, id, "New pattern", QColor::fromHsl(162, 50, 43));
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

// Adds a pattern and returns its ID
QString Song::addPattern(QString name, QColor color) {
    QString patternID = QString::number(id->get());

    this->addPattern(patternID, name, color);

    return patternID;
}

void Song::addPattern(QString id, QString name, QColor color) {
    Value patchVal(kObjectType);


    Value nameVal;
    setStr(nameVal, name, getPatchAllocator());

    Value colorVal;
    setStr(colorVal, color.name(), getPatchAllocator());


    patchVal.AddMember("display_name", nameVal, getPatchAllocator());
    patchVal.AddMember("color", colorVal, getPatchAllocator());

    patchAdd("patterns/" + id, patchVal);


    patterns[id] = new Pattern(this, this->id, name, color);

    sendPatch();

    emit patternAdd(id);
}

void Song::removePattern(QString id) {
    patchRemove("patterns/" + id);

    delete patterns[id];
    patterns.remove(id);

    sendPatch();

    emit patternRemove(id);
}

const QHash<QString, Pattern*>& Song::getPatterns() {
    return this->patterns;
}

Pattern* Song::getPattern(QString key) {
    return this->patterns[key];
}
