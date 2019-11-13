/*
    Copyright (C) 2019 Joshua Wade

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

#include "modelitem.h"

ModelItem::ModelItem(Communicator* parent, QString jsonKey) : Communicator(static_cast<QObject*>(parent))
{
    this->parent = parent;
    this->key = jsonKey;
}

ModelItem::~ModelItem() {}

void ModelItem::patchAdd(QString path, rapidjson::Value& value) {
    parent->patchAdd(
        key + "/" + path,
        value
    );
}

void ModelItem::patchRemove(QString path, rapidjson::Value& oldValue) {
    parent->patchRemove(
        key + "/" + path,
        oldValue
    );
}

void ModelItem::patchReplace(QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue) {
    parent->patchReplace(
        key + "/" + path,
        oldValue,
        newValue
    );
}

void ModelItem::patchCopy(QString from, QString path) {
    parent->patchCopy(
        key + "/" + from,
        key + "/" + path
    );
}

void ModelItem::patchMove(QString from, QString path) {
    parent->patchMove(
        key + "/" + from,
        key + "/" + path
    );
}

void ModelItem::sendPatch() {
    parent->sendPatch();
}

void ModelItem::liveUpdate(uint64_t controlId, float value) {
    parent->liveUpdate(controlId, value);
}
