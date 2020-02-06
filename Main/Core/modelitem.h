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

#ifndef MODELITEM_H
#define MODELITEM_H

#include <QObject>

#include "communicator.h"
#include "Utilities/patchfragment.h"

#include "Include/rapidjson/document.h"

class ModelItem : public Communicator {
    Q_OBJECT
private:
    QString key;
public:
    /// Apply a patch to the C++ model. Used for undo and redo.
    /// "pointer" is expected to be relative to the ModelItem this
    ///     function is called on.
    virtual void onPatchReceived(
                QStringRef pointer,
                PatchFragment& patch
            ) = 0;

    /// Serialize model item state into the given value
    virtual void serialize(
                rapidjson::Value& value,
                rapidjson::Document& doc
            ) = 0;

    ModelItem(Communicator* parent, QString jsonKey);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path, rapidjson::Value& oldValue);
    void patchReplace(
        QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue
    );
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();
    void liveUpdate(uint64_t controlId, float value);
    rapidjson::Document::AllocatorType& getPatchAllocator();

    /// Utility function to generate a rapidjson value from a string
    void setStr(rapidjson::Value& target, QString str,
                rapidjson::Document::AllocatorType& allocator);

    Communicator* parent;

    virtual ~ModelItem();
};

#endif // MODELITEM_H
