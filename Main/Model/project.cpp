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

using namespace rapidjson;

Project::Project(Communicator* parent, IdGenerator* id)
                    : ModelItem(parent, "project") {
    this->id = id;
    transport = new Transport(this, id);
    song = new Song(this, id);
}

Project::Project(Communicator* parent, IdGenerator* id,
                 Value& projectVal)
                    : ModelItem(parent, "project") {
    this->id = id;
    transport =
        new Transport(this, id, projectVal["transport"]);
    song =
        new Song(this, id, projectVal["song"]);
}

void Project::onPatchReceived(QStringRef pointer, PatchFragment& patch) {
    QString transportStr = "/transport";
    QString songStr = "/song";
    if (pointer.startsWith(transportStr)) {
        transport->onPatchReceived(
            pointer.mid(transportStr.length()), patch
        );
    }
    else if (pointer.startsWith(songStr)) {
        song->onPatchReceived(
            pointer.mid(songStr.length()), patch
        );
    }
}

void Project::serialize(Value& value, Document::AllocatorType& allocator) {
    value.SetObject();

    Value transportValue;
    transport->serialize(transportValue, allocator);
    value.AddMember("transport", transportValue, allocator);

    Value songValue;
    song->serialize(songValue, allocator);
    value.AddMember("song", songValue, allocator);
}

Transport* Project::getTransport() {
    return this->transport;
}

Song* Project::getSong() {
    return this->song;
}
