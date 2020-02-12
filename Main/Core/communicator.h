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

#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>
#include <QString>

#include "Include/rapidjson/document.h"

class Communicator : public QObject {
public:
    explicit Communicator(QObject* parent);
    virtual void sendPatch() = 0;
    virtual void liveUpdate(uint64_t controlId, float value) = 0;
    virtual void patchAdd(QString path, rapidjson::Value& value) = 0;
    virtual void patchRemove(QString path, rapidjson::Value& oldValue) = 0;
    virtual void patchReplace(QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue) = 0;
    virtual void patchCopy(QString from, QString path) = 0;
    virtual void patchMove(QString from, QString path) = 0;
    virtual rapidjson::Document::AllocatorType& getPatchAllocator() = 0;
    virtual rapidjson::Document::AllocatorType& getUndoPatchAllocator() = 0;
};

#endif // COMMUNICATOR_H
