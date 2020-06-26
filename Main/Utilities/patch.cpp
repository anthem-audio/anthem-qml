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

#include "patch.h"
#include "Include/rapidjson/pointer.h"

using namespace rapidjson;

Patch::Patch(QObject* parent) : QObject(parent)
{
    patch.SetArray();
}

void Patch::patchAdd(
    QString path, rapidjson::Value &value
) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    addFragmentToForward(forwardFragment);
}

void Patch::patchRemove(QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
}

void Patch::patchReplace(
    QString path,
    rapidjson::Value& newValue
) {
    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                newValue);

    addFragmentToForward(forwardFragment);
}

void Patch::patchCopy(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
}

void Patch::patchMove(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
}

Value& Patch::getPatch() {
    if (patch.IsArray())
        patch.Clear();
    else
        patch.SetArray();

    for (int i = 0; i < patchList.length(); i++) {
        patch.PushBack(
            Value(
                patchList[i]->patch, patch.GetAllocator()
            ), patch.GetAllocator()
        );
    }

    return patch;
}

void Patch::addFragmentToForward(PatchFragment* fragment) {
    patchList.append(fragment);
}

Document::AllocatorType* Patch::getPatchAllocator() {
    return &patch.GetAllocator();
}
