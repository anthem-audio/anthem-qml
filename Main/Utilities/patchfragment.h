#ifndef PATCHFRAGMENT_H
#define PATCHFRAGMENT_H

#include <QObject>
#include <QString>

#include "Include/rapidjson/document.h"

/// Describes one step of a patch
class PatchFragment : QObject {
Q_OBJECT
public:
    enum PatchType {
        ADD,
        REMOVE,
        REPLACE,
        COPY,
        MOVE
    };
private:
    PatchType type;
public:
    rapidjson::Value patch;

    PatchFragment(QObject* parent, rapidjson::Document& doc, PatchType type, QString from, QString path, rapidjson::Value& value);
    PatchType getType();
    void apply(rapidjson::Document& doc);
};

#endif // PATCHFRAGMENT_H
