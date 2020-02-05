#ifndef DEBUG_H
#define DEBUG_H

#include <QDebug>

#include "Include/rapidjson/document.h"
#include "Include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/prettywriter.h"

using namespace rapidjson;

namespace AnthemDebug {
    void qDebugJsonValue(Value& val) {
        StringBuffer buffer;
        PrettyWriter<StringBuffer> writer(buffer);
        val.Accept(writer);
        const char* json = buffer.GetString();
        qDebug() << json;
    }
}

#endif // DEBUG_H
