#ifndef PATCHFRAGMENT_H
#define PATCHFRAGMENT_H

#include <QString>

#include "Include/rapidjson/document.h"

/// Describes one step of a patch
class PatchFragment
{
public:
    enum PatchType {
        ADD,
        REMOVE,
        REPLACE,
        COPY,
        MOVE
    };

    rapidjson::Value patch;

    PatchFragment(rapidjson::Document& doc, PatchType type, QString from, QString path, rapidjson::Value& value);
};

#endif // PATCHFRAGMENT_H
