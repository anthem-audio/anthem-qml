#ifndef PATCH_H
#define PATCH_H

#include <QObject>
#include <QString>
#include <QVector>

#include "Include/rapidjson/document.h"

#include "patchfragment.h"

class Patch : QObject {
Q_OBJECT
    rapidjson::Document* project;

    rapidjson::Value patch;
    rapidjson::Value undoPatch;

    QVector<PatchFragment*> patchList;
    QVector<PatchFragment*> undoPatchList;

    void addFragmentToForward(PatchFragment* fragment);
    void addFragmentToReverse(PatchFragment* fragment);
public:
    Patch(QObject* parent, rapidjson::Document& project);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);

    rapidjson::Value& getPatch();
    rapidjson::Value& getUndoPatch();
};

#endif // PATCH_H
