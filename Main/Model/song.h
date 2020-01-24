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

#ifndef SONG_H
#define SONG_H

#include <QObject>
#include <QHash>

#include "Include/rapidjson/document.h"

#include "Core/modelitem.h"
#include "Utilities/idgenerator.h"

#include "Model/pattern.h"

class Song : public ModelItem {
    Q_OBJECT
private:
    IdGenerator* id;
    QHash<uint64_t, Pattern*> patterns;
public:
    Song(ModelItem* parent, IdGenerator* id);
    Song(ModelItem* parent, IdGenerator* id, rapidjson::Value& songNode);

    void onPatchReceived(QStringRef pointer, PatchFragment& patch) override;
    void serialize(rapidjson::Value& value, rapidjson::Document& doc) override;
};

#endif // SONG_H
