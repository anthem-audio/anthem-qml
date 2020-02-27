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

#ifndef PATCHFRAGMENT_H
#define PATCHFRAGMENT_H

#include <QObject>
#include <QString>

#include "Include/rapidjson/document.h"

/// Describes one step of a patch
class PatchFragment : QObject {
Q_OBJECT
public:
    enum PatchType {
        ADD,
        REMOVE,
        REPLACE,
        COPY,
        MOVE
    };
private:
    PatchType type;
public:
    rapidjson::Document patch;

    PatchFragment(
        QObject* parent,
        PatchType type,
        QString from,
        QString path,
        rapidjson::Value& value
    );
    PatchType getType();
    void apply(rapidjson::Document& doc);
};

#endif // PATCHFRAGMENT_H
