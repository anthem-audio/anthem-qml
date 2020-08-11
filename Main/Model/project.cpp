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

#include "Utilities/exceptions.h"

Project::Project(Communicator* parent, IdGenerator* id)
                    : ModelItem(parent, "project") {
    this->id = id;
    transport = new Transport(this, id);
    song = new Song(this, id);
}

Project::Project(Communicator* parent, IdGenerator* id,
                 QJsonObject& projectVal)
                    : ModelItem(parent, "project") {
    this->id = id;

    QJsonObject transportVal = projectVal["transport"].toObject();
    transport = new Transport(this, id, transportVal);

    QJsonObject songVal = projectVal["song"].toObject();
    song = new Song(this, id, songVal);
}

void Project::serialize(QJsonObject& node) {
    QJsonObject transportValue;
    transport->serialize(transportValue);
    node["transport"] = transportValue;

    QJsonObject songValue;
    song->serialize(songValue);
    node["song"] = songValue;
}

Transport* Project::getTransport() {
    return this->transport;
}

Song* Project::getSong() {
    return this->song;
}
