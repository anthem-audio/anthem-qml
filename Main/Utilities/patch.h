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
    Project* cppModel;
    rapidjson::Document* jsonModel;

    rapidjson::Value patch;
    rapidjson::Value undoPatch;

    QVector<PatchFragment*> patchList;
    QVector<PatchFragment*> undoPatchList;

    void addFragmentToForward(PatchFragment* fragment);
    void addFragmentToReverse(PatchFragment* fragment);
public:
    Patch(QObject* parent, Project* cppModel, rapidjson::Document& jsonModel);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);

    rapidjson::Value& getPatch();
    rapidjson::Value& getUndoPatch();

    /// Apply this patch to the project provided in the constructor
    void apply();

    /// Apply the contained undo operation to the project provided in the constructor
    void applyUndo();
};

#endif // PATCH_H
