#ifndef PATCH_H
#define PATCH_H

#include <QObject>
#include <QString>
#include <QVector>

#include "Include/rapidjson/document.h"

#include "patchfragment.h"

class Patch : QObject {
Q_OBJECT
    rapidjson::Value patch;
    rapidjson::Value undoPatch;

    void addFragmentToPatch(PatchFragment& source, rapidjson::Value& destination);
    void addFragmentToForward(PatchFragment& fragment);
    void addFragmentToReverse(PatchFragment& fragment);
public:
    Patch(QObject* parent, rapidjson::Document& project);

    void patchAdd(QString path, rapidjson::Value& value);
    void patchRemove(QString path);
    void patchReplace(QString path, rapidjson::Value& value);
    void patchCopy(QString from, QString path);
    void patchMove(QString from, QString path);

    rapidjson::Value& getPatch();
    rapidjson::Value& getUndoPatch();

    rapidjson::Document* project;
};

#endif // PATCH_H
