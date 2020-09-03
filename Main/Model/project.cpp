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

#include "project.h"

#include <QJsonArray>

#include "Utilities/exceptions.h"

#include "controller.h"
#include "instrument.h"

Project::Project(Communicator* parent, IdGenerator* id)
                    : ModelItem(parent, "project") {
    this->id = id;
    this->transport = new Transport(this, id);
    this->song = new Song(this, id);
    this->generators = QHash<QString, Generator*>();
    this->generatorOrder = QVector<QString>();
    this->notes = "";
}

Project::Project(Communicator* parent, IdGenerator* id,
                 QJsonObject& projectVal)
                    : ModelItem(parent, "project") {
    this->id = id;

    QJsonObject transportVal = projectVal["transport"].toObject();
    this->transport = new Transport(this, id, transportVal);

    QJsonObject songVal = projectVal["song"].toObject();
    this->song = new Song(this, id, songVal);

    QJsonObject generatorsVal = projectVal["generators"].toObject();
    for (const QString& key : generatorsVal.keys()) {
        QJsonObject generatorValue = generatorsVal[key].toObject();
        auto type = generatorValue["type"].toString();
        if (type == "controller") {
            this->generators[key] = new Controller(this, this->id, generatorValue);
        }
        else if (type == "instrument") {
            this->generators[key] = new Instrument(this, this->id, generatorValue);
        }
    }

    QJsonArray generatorOrderVal = projectVal["generator_order"].toArray();
    // https://stackoverflow.com/a/49979209/8166701
    for (auto&& keyAsUnknown : generatorOrderVal) {
        auto key = keyAsUnknown.toString();
        this->generatorOrder.push_back(key);
    }

    this->notes = projectVal["notes"].toString();
}

void Project::serialize(QJsonObject& node) const {
    QJsonObject transportValue;
    this->transport->serialize(transportValue);
    node["transport"] = transportValue;

    QJsonObject songValue;
    this->song->serialize(songValue);
    node["song"] = songValue;

    QJsonObject generatorsValue;
    QHashIterator<QString, Generator*> iter(generators);
    while (iter.hasNext()) {
        iter.next();

        const Generator* generator = iter.value();
        const Controller* controller = dynamic_cast<const Controller*>(generator);
        const Instrument* instrument = dynamic_cast<const Instrument*>(generator);

        QJsonObject thisGeneratorValue;
        if (controller != nullptr) {
            controller->serialize(thisGeneratorValue);
            thisGeneratorValue["type"] = "controller";
        }
        else if (instrument != nullptr) {
            instrument->serialize(thisGeneratorValue);
            thisGeneratorValue["type"] = "instrument";
        }
        generatorsValue[iter.key()] = thisGeneratorValue;
    }
    node["generators"] = generatorsValue;

    QJsonArray generatorOrderValue;
    for (QString key : generatorOrder) {
        generatorOrderValue.push_back(key);
    }
    node["generator_order"] = generatorOrderValue;

    node["notes"] = this->notes;
}

Transport* Project::getTransport() {
    return this->transport;
}

Song* Project::getSong() {
    return this->song;
}

QString Project::getNotes() {
    return this->notes;
}

void Project::setNotes(QString notes) {
    this->notes = notes;
}
