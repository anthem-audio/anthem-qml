#include "patchfragment.h"

#include "Include/rapidjson/pointer.h"
#include "Include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/writer.h"

using namespace rapidjson;

PatchFragment::PatchFragment(QObject* parent, Document& doc, PatchType type, QString from, QString path, rapidjson::Value& value) : QObject(parent) {
    patch.SetObject();

    QString op;

    this->type = type;

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

PatchFragment::PatchType PatchFragment::getType() {
    return type;
}

void PatchFragment::apply(Document &doc) {
    switch (type) {
        case PatchType::ADD:
            Pointer(patch["path"].GetString())
                    .Set(doc, Value(patch["value"], doc.GetAllocator()));
            break;
        case PatchType::REMOVE:
            Pointer(patch["path"].GetString())
                    .Erase(doc);
            break;
        case PatchType::REPLACE:
            Pointer(patch["path"].GetString())
                    .Set(doc, Value(patch["value"], doc.GetAllocator()));
            break;
        case PatchType::COPY:
            Pointer(patch["path"].GetString())
                    .Set(doc, Value(
                             Pointer(patch["from"].GetString()).GetWithDefault(doc, kNullType), doc.GetAllocator()
                         ));
            break;
        case PatchType::MOVE:
            Pointer(patch["path"].GetString())
                    .Set(doc, Value(
                        Pointer(patch["from"].GetString()).GetWithDefault(doc, kNullType), doc.GetAllocator()
                    ));
            Pointer(patch["from"].GetString())
                    .Erase(doc);
            break;
    }
}
