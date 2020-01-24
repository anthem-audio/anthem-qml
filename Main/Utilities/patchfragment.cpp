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

#include "patchfragment.h"

#include "Include/rapidjson/pointer.h"
#include "Include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/writer.h"

using namespace rapidjson;

PatchFragment::PatchFragment(
                QObject* parent,
                PatchType type,
                QString from,
                QString path,
                rapidjson::Value& value
            ) : QObject(parent)
{
    patch.SetObject();

    QString op;

    this->type = type;

    if (type == PatchType::ADD)
        op = "add";
    else if (type == PatchType::REMOVE)
        op = "remove";
    else if (type == PatchType::REPLACE)
        op = "replace";
    else if (type == PatchType::COPY)
        op = "copy";
    else if (type == PatchType::MOVE)
        op = "move";

    Value opVal(kStringType);
    opVal.SetString(op.toStdString(), patch.GetAllocator());

    patch.AddMember("op", opVal, patch.GetAllocator());

    if (!from.isNull()) {
        patch.AddMember(
            "from", from.toStdString(), patch.GetAllocator()
        );
    }

    patch.AddMember(
        "path", path.toStdString(), patch.GetAllocator()
    );

    if (!value.IsNull()) {
        patch.AddMember(
            "value", value, patch.GetAllocator()
        );
    }
}

PatchFragment::PatchType PatchFragment::getType() {
    return type;
}

void PatchFragment::apply(Document &doc) {
    switch (type) {
        case PatchType::ADD:
            Pointer(
                patch["path"].GetString()
            ).Set(
                doc, Value(
                    patch["value"], doc.GetAllocator()
                )
            );
            break;
        case PatchType::REMOVE:
            Pointer(
                patch["path"].GetString()
            ).Erase(doc);
            break;
        case PatchType::REPLACE:
            Pointer(
                patch["path"].GetString()
            ).Set(
                doc, Value(
                    patch["value"], doc.GetAllocator()
                )
            );
            break;
        case PatchType::COPY:
            Pointer(
                patch["path"].GetString()
            ).Set(
                doc, Value(
                    Pointer(
                        patch["from"].GetString()
                    ).GetWithDefault(doc, kNullType),
                    doc.GetAllocator()
                )
            );
            break;
        case PatchType::MOVE:
            Pointer(
                patch["path"].GetString()
            ).Set(
                doc, Value(
                    Pointer(
                        patch["from"].GetString()
                    ).GetWithDefault(doc, kNullType),
                    doc.GetAllocator()
                )
            );
            Pointer(patch["from"].GetString()).Erase(doc);
            break;
    }
}
