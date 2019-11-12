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

#ifndef PATCH_H
#define PATCH_H

#include <QObject>
#include <QString>
#include <QVector>

#include "Include/rapidjson/document.h"

#include "patchfragment.h"
#include "Model/project.h"

class Patch : QObject {
Q_OBJECT
    Project* model;

    rapidjson::Document patch;
    rapidjson::Document undoPatch;

    QVector<PatchFragment*> patchList;
    QVector<PatchFragment*> undoPatchList;

    void addFragmentToForward(PatchFragment* fragment);
    void addFragmentToReverse(PatchFragment* fragment);
public:
    Patch(QObject* parent, Project* model);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path, rapidjson::Value& oldValue);
    void patchReplace(QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);

    rapidjson::Document::AllocatorType* getPatchAllocator();
    rapidjson::Document::AllocatorType* getUndoPatchAllocator();

    rapidjson::Value& getPatch();
    rapidjson::Value& getUndoPatch();

    /// Apply this patch to the project provided in the constructor
    void apply();

    /// Apply the contained undo operation to the project provided in the constructor
    void applyUndo();
};

#endif // PATCH_H
