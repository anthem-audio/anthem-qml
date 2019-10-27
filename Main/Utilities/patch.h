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
