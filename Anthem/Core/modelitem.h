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
#include <QJsonValue>
#include <QJsonObject>

#include "communicator.h"
#include "Utilities/patchfragment.h"

class ModelItem : public Communicator {
    Q_OBJECT
private:
    QString key;
public:
    /// Serialize model item state into the given value
    virtual void serialize(QJsonObject& node) const = 0;

    ModelItem(Communicator* parent, QString jsonKey);

    void patchAdd(QString path, QJsonValue& value);
    void patchRemove(QString path);
    void patchReplace(QString path, QJsonValue& newValue);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);
    void sendPatch();
    void liveUpdate(quint64 controlId, float value);

    Communicator* parent;

    virtual ~ModelItem();
};

#endif // MODELITEM_H
