#include "patchfragment.h"

using namespace rapidjson;

PatchFragment::PatchFragment(Document& doc, PatchType type, QString from, QString path, rapidjson::Value& value) {
    patch.SetObject();

    QString op;

    if (type == PatchType::ADD)
        op = "add";
    else if (type == PatchType::REMOVE)
        op = "remove";
    else if (type == PatchType::REPLACE)
        op = "replace";
    else if (type == PatchType::COPY)
        op = "copy";
    else if (type == PatchType::MOVE)
        op = "move";

    Value opVal(kStringType);
    opVal.SetString(op.toStdString(), doc.GetAllocator());

    patch.AddMember("op", opVal, doc.GetAllocator());

    if (!from.isNull()) {
        patch.AddMember("from", from.toStdString(), doc.GetAllocator());
    }

    patch.AddMember("path", path.toStdString(), doc.GetAllocator());

    if (!value.IsNull()) {
        patch.AddMember("value", value, doc.GetAllocator());
    }
}
