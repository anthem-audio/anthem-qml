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

    PatchFragment forwardFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::ADD,
                QString(),
                path,
                value);

    PatchFragment reverseFragment = PatchFragment(
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

    PatchFragment forwardFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::REMOVE,
                QString(),
                path,
                nullVal);

    PatchFragment reverseFragment = PatchFragment(
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

void Patch::patchReplace(QString path, rapidjson::Value &value) {
    PatchFragment forwardFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::REPLACE,
                QString(),
                path,
                value);

    PatchFragment reverseFragment = PatchFragment(
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

    PatchFragment forwardFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::COPY,
                from,
                path,
                nullVal);

    PatchFragment reverseFragment = PatchFragment(
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

    PatchFragment forwardFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::MOVE,
                from,
                path,
                nullVal);

    PatchFragment reverseFragment = PatchFragment(
                *project,
                PatchFragment::PatchType::MOVE,
                path,
                from,
                nullVal);

    addFragmentToForward(forwardFragment);
    addFragmentToReverse(reverseFragment);
}

Value& Patch::getPatch() {
    return patch;
}

Value& Patch::getUndoPatch() {
    return undoPatch;
}

void Patch::addFragmentToForward(PatchFragment& fragment) {
    patch.PushBack(fragment.patch, project->GetAllocator());
}

void Patch::addFragmentToReverse(PatchFragment& fragment) {
    undoPatch.PushFront(fragment.patch, project->GetAllocator());
}
