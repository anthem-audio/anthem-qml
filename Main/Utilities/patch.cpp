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

Patch::Patch(QObject* parent) : QObject(parent)
{
}

void Patch::patchAdd(
    QString path, QJsonValue &value
) {
    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    addFragmentToForward(forwardFragment);
}

void Patch::patchRemove(QString path) {
    QJsonValue nullVal(QJsonValue::Null);

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
    QJsonValue& newValue
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
    QJsonValue nullVal(QJsonValue::Null);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
}

void Patch::patchMove(QString from, QString path) {
    QJsonValue nullVal(QJsonValue::Null);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
}

QJsonArray& Patch::getPatch() {
    for (int i = 0; i < patchList.length(); i++) {
        patch.push_back(patchList[i]->patch);
    }

    return patch;
}

void Patch::addFragmentToForward(PatchFragment* fragment) {
    patchList.append(fragment);
}

//Document::AllocatorType* Patch::getPatchAllocator() {
//    return &patch.GetAllocator();
//}
