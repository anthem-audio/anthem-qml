#include "patch.h"
#include "Include/rapidjson/pointer.h"

using namespace rapidjson;

Patch::Patch(QObject* parent, Document& project) : QObject(parent)
{
    project.GetAllocator();
    (&project)->GetAllocator();

    this->project = &project;

    patch.SetArray();
    undoPatch.SetArray();
}

void Patch::patchAdd(QString path, rapidjson::Value &value) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *project,
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
                *project,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                Pointer(path.toStdString())
                    .GetWithDefault(*project, kNullType));

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

// TODO: these things lol

void Patch::patchReplace(QString path, rapidjson::Value& value) {
    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                value);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                Pointer(path.toStdString())
                    .GetWithDefault(*project, kNullType));

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

void Patch::patchCopy(QString from, QString path) {
    Value nullVal(kNullType);

    PatchFragment* forwardFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *project,
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
                *project,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    PatchFragment* reverseFragment = new PatchFragment(
                this,
                *project,
                PatchFragment::PatchType::MOVE,
                path,
                from,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

Value& Patch::getPatch() {
    patch.Clear();
    for (int i = 0; i < patchList.length(); i++) {
        patch.PushBack(patchList[i]->patch, project->GetAllocator());
    }
    return patch;
}

Value& Patch::getUndoPatch() {
    undoPatch.Clear();
    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
        undoPatch.PushBack(undoPatchList[i]->patch, project->GetAllocator());
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
        patchList[i]->apply(*project);
    }
}

void Patch::applyUndo() {
    for (int i = undoPatchList.length() - 1; i >= 0; i--) {
        undoPatchList[i]->apply(*project);
    }
}
