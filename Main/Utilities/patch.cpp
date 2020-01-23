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

#include "patch.h"
#include "Include/rapidjson/pointer.h"

using namespace rapidjson;

Patch::Patch(QObject* parent, Project* model) : QObject(parent)
{
    this->model = model;

    patch.SetArray();
    undoPatch.SetArray();
}

void Patch::patchAdd(QString path, rapidjson::Value &value) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchRemove(QString path, Value& oldValue) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                oldValue);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchReplace(QString path, rapidjson::Value& oldValue, rapidjson::Value& newValue) {
    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                newValue);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                oldValue);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchCopy(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchMove(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::MOVE,
                path,
                from,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

Value& Patch::getPatch() {
    if (patch.IsArray())
        patch.Clear();
    else
        patch.SetArray();

    for (int i = 0; i < patchList.length(); i++) {
        patch.PushBack(Value(patchList[i]->patch, patch.GetAllocator()), patch.GetAllocator());
    }

    return patch;
}

Value& Patch::getUndoPatch() {
    if (undoPatch.IsArray())
        undoPatch.Clear();
    else
        undoPatch.SetArray();

    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
        undoPatch.PushBack(Value(undoPatchList[i]->patch, patch.GetAllocator()), patch.GetAllocator());
    }

    return undoPatch;
}

void Patch::addFragmentToForward(PatchFragment* fragment) {
    patchList.append(fragment);
}

void Patch::addFragmentToReverse(PatchFragment* fragment) {
    undoPatchList.append(fragment);
}

void Patch::apply() {
    for (int i = 0; i < patchList.length(); i++) {
//        patchList[i]->apply(*jsonModel);

        // Update C++ model and UI
        QString path(patchList[i]->patch["path"].GetString());
        model->onPatchReceived(QStringRef(&path).mid(QString("/project").length()), *patchList[i]);
    }
}

void Patch::applyUndo() {
    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
//        undoPatchList[i]->apply(*jsonModel);

        // Update C++ model and UI
        QString path(undoPatchList[i]->patch["path"].GetString());
        model->onPatchReceived(QStringRef(&path).mid(QString("/project").length()), *undoPatchList[i]);
    }
}

Document::AllocatorType* Patch::getPatchAllocator() {
    return &patch.GetAllocator();
}

Document::AllocatorType* Patch::getUndoPatchAllocator() {
    return &undoPatch.GetAllocator();
}
