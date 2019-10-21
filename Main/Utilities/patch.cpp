#include "patch.h"
#include "Include/rapidjson/pointer.h"

using namespace rapidjson;

Patch::Patch(QObject* parent, Project* cppModel, Document& jsonModel) : QObject(parent)
{
    this->cppModel = cppModel;
    this->jsonModel = &jsonModel;

    patch.SetArray();
    undoPatch.SetArray();
}

void Patch::patchAdd(QString path, rapidjson::Value &value) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchRemove(QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    Value undoVal(Pointer(path.toStdString())
                        .GetWithDefault(*jsonModel, kNullType),
                  jsonModel->GetAllocator());

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                undoVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchReplace(QString path, rapidjson::Value& value) {
    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                value);

    Value undoVal(Value(Pointer(path.toStdString())
                        .GetWithDefault(*jsonModel, kNullType),
                  jsonModel->GetAllocator()));

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                undoVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchCopy(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *jsonModel,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *jsonModel,
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
                *jsonModel,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *jsonModel,
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
        patch.PushBack(Value(patchList[i]->patch, jsonModel->GetAllocator()), jsonModel->GetAllocator());
    }

    return patch;
}

Value& Patch::getUndoPatch() {
    if (undoPatch.IsArray())
        undoPatch.Clear();
    else
        undoPatch.SetArray();

    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
        undoPatch.PushBack(Value(undoPatchList[i]->patch, jsonModel->GetAllocator()), jsonModel->GetAllocator());
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
        patchList[i]->apply(*jsonModel);

        // Update C++ model and UI
        QString path(patchList[i]->patch["path"].GetString());
        cppModel->externalUpdate(QStringRef(&path).mid(QString("/project").length()), *patchList[i]);
    }
}

void Patch::applyUndo() {
    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
        undoPatchList[i]->apply(*jsonModel);

        // Update C++ model and UI
        QString path(undoPatchList[i]->patch["path"].GetString());
        cppModel->externalUpdate(QStringRef(&path).mid(QString("/project").length()), *undoPatchList[i]);
    }
}
