#include "engine.h"

#include "Include/rapidjson/include/rapidjson/document.h"
#include "Include/rapidjson/include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/include/rapidjson/writer.h"

#include <QDebug>

using namespace rapidjson;

Engine::Engine(QObject* parent) : QObject(parent)
{
    engine = new QProcess(this);
    QObject::connect(engine, &QProcess::started,
                     this,   &Engine::onEngineStart);
    QObject::connect(engine, &QProcess::readyRead,
                     this,   &Engine::onEngineMessageChunk);
    engine->setReadChannel(QProcess::ProcessChannel::StandardOutput);
    engine->setProcessChannelMode(QProcess::ProcessChannelMode::MergedChannels);
}

// TODO: propagate errors to user
void Engine::start() {
    engine->start("mock-engine");
}

// TODO: propagate errors to user
void Engine::stop() {
    engine->kill();
}

void Engine::onEngineStart() {
//    sendLiveControlUpdate(0, 0.123f);
//    engine->write("\n");
}

void Engine::onEngineMessageChunk() {
    qDebug() << engine->readAllStandardOutput();
}

void Engine::sendLiveControlUpdate(uint64_t controlId, float value) {
    Document json;
    json.SetObject();
    Document::AllocatorType& allocator = json.GetAllocator();

    Value jsonrpcVal(Type::kStringType);
    jsonrpcVal.SetString("2.0");

    Value methodVal(Type::kStringType);
    methodVal.SetString("control_live_update");

    json.AddMember("jsonrpc", jsonrpcVal, allocator);
    json.AddMember("method", methodVal, allocator);

    Value params(Type::kObjectType);

    Value controlIdVal(Type::kNumberType);
    controlIdVal.SetUint64(controlId);

    Value valueVal(Type::kNumberType);
    valueVal.SetFloat(value);

    params.AddMember("control_id", controlIdVal, allocator);
    params.AddMember("value", valueVal, allocator);

    json.AddMember("params", params, allocator);

    StringBuffer buffer;
    Writer<StringBuffer> writer(buffer);
    json.Accept(writer);

    const char* output = buffer.GetString();
    engine->write(output);
}
