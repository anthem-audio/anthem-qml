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

Song::Song(ModelItem* parent, IdGenerator* id) : ModelItem(parent, "song") {
    this->id = id;
    this->patterns = QHash<QString, Pattern*>();
    patterns[QString::number(id->get())] = new Pattern(this, id, "New pattern", QColor::fromHsl(162, 50, 43));
}

Song::Song(ModelItem* parent, IdGenerator* id, QJsonObject& node)
            : ModelItem(parent, "song") {
    this->id = id;
    QJsonObject patternMap = node["patterns"].toObject();
    for (auto key : patternMap.keys()) {
        QString patternId(key);
        QJsonObject patternNode = patternMap[key].toObject();
        this->patterns[patternId] = new Pattern(this, id, patternNode);
    }
}

void Song::serialize(QJsonObject& node) const {
    QJsonObject patterns;
    auto keys = this->patterns.keys();
    for (QString key : keys) {
        QJsonObject v;
        this->patterns[key]->serialize(v);
        patterns[key] = v;
    }

    node["patterns"] = patterns;
}

// Adds a pattern and returns its ID
QString Song::addPattern(QString name, QColor color) {
    QString patternID = QString::number(id->get());

    this->addPattern(patternID, name, color);

    return patternID;
}

void Song::addPattern(QString id, QString name, QColor color) {
    QJsonObject patchObj;

    patchObj["display_name"] = name;
    patchObj["color"] = color.name();

    QJsonValue patchVal = patchObj;

    patchAdd("patterns/" + id, patchVal);

    patterns[id] = new Pattern(this, this->id, name, color);

    sendPatch();
}

void Song::removePattern(QString id) {
    patchRemove("patterns/" + id);

    delete patterns[id];
    patterns.remove(id);

    sendPatch();
}

const QHash<QString, Pattern*>& Song::getPatterns() {
    return this->patterns;
}

Pattern* Song::getPattern(QString key) {
    return this->patterns[key];
}
