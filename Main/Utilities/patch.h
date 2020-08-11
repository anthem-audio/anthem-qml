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

#ifndef PATCH_H
#define PATCH_H

#include <QObject>
#include <QString>
#include <QVector>
#include <QJsonArray>
#include <QJsonValue>

#include "patchfragment.h"
#include "Model/project.h"

class Patch : QObject {
Q_OBJECT
    QJsonArray patch;

    QVector<PatchFragment*> patchList;

    void addFragmentToForward(PatchFragment* fragment);
public:
    Patch(QObject* parent);

    void patchAdd(QString path, QJsonValue& value);
    void patchRemove(QString path);
    void patchReplace(QString path, QJsonValue& newValue);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);

    QJsonArray& getPatch();
};

#endif // PATCH_H
