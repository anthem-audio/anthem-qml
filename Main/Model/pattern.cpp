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

#include "pattern.h"

using namespace rapidjson;

Pattern::Pattern(
        ModelItem* parent,
        IdGenerator* id,
        QString displayName
) : ModelItem(parent, "pattern") {
    this->id = id;
    this->displayName = displayName;
}

Pattern::Pattern(
        ModelItem* parent,
        IdGenerator* id,
        Value& patternNode
) : ModelItem(parent, "pattern") {
    this->id = id;
    this->displayName =
        patternNode["display_name"].GetString();
}

void Pattern::onPatchReceived(
        QStringRef pointer,
        PatchFragment& patch
) {
    QString displayNameStr = "/display_name";

    if (pointer.startsWith(displayNameStr)) {
        this->displayName =
            patch.patch["value"].GetString();

        emit displayNameChanged(displayName);
    }
}

void Pattern::serialize(
        Value& value, Document& doc
) {
    value.SetObject();

    auto displayNameStr =
        this->displayName.toStdString();

    Value displayNameValue(
        displayNameStr.c_str(),
        static_cast<SizeType>(
            displayNameStr.size()
        ),
        doc.GetAllocator()
    );

    value.AddMember(
        "display_name",
        displayNameValue,
        doc.GetAllocator()
    );
}
