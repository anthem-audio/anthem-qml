#include "engine.h"

#include <QDebug>

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
    emit engineStarted();
}

void Engine::onEngineMessageChunk() {
    qDebug() << engine->readAllStandardOutput();
}

void Engine::write(Document &json) {
    StringBuffer buffer;
    Writer<StringBuffer> writer(buffer);
    json.Accept(writer);

    const char* output = buffer.GetString();
    engine->write(output);
}

void Engine::addRPCHeaders(Document &json, Document::AllocatorType& allocator) {
    Value jsonrpcVal(Type::kStringType);
    jsonrpcVal.SetString("2.0");

    json.AddMember("jsonrpc", jsonrpcVal, allocator);
}

/*
 * {
 *   "jsonrpc": "2.0",
 *   "method": "ControlUpdate",
 *   "params": {
 *     "control_id": (uint64)
 *     "value": (float)
 *   }
 * }
 */
void Engine::sendLiveControlUpdate(uint64_t controlId, float value) {
    Document json;
    json.SetObject();
    Document::AllocatorType& allocator = json.GetAllocator();

    addRPCHeaders(json, allocator);

    Value methodVal(Type::kStringType);
    methodVal.SetString("ControlUpdate");

    json.AddMember("method", methodVal, allocator);

    Value params(Type::kObjectType);

    Value controlIdVal(Type::kNumberType);
    controlIdVal.SetUint64(controlId);

    Value valueVal(Type::kNumberType);
    valueVal.SetFloat(value);

    params.AddMember("control_id", controlIdVal, allocator);
    params.AddMember("value", valueVal, allocator);

    json.AddMember("params", params, allocator);

    write(json);
}

/*
 * {
 *   "jsonrpc": "2.0",
 *   "method": "MidiNoteEvent",
 *   "params": {
 *     "generator_id": (uint64)
 *     "message": [(uint8), (uint8), (uint8)]
 *   }
 * }
 */
void Engine::sendMidiNoteEvent(uint64_t generatorId, uint8_t status, uint8_t data1, uint8_t data2) {
    Document json;
    json.SetObject();
    Document::AllocatorType& allocator = json.GetAllocator();

    addRPCHeaders(json, allocator);

    Value methodVal(Type::kStringType);
    methodVal.SetString("MidiNoteEvent");

    json.AddMember("method", methodVal, allocator);

    Value params(Type::kObjectType);

    Value generatorIdVal(Type::kNumberType);
    generatorIdVal.SetUint64(generatorId);

    Value statusVal(Type::kNumberType);
    statusVal.SetUint(status);

    Value data1Val(Type::kNumberType);
    data1Val.SetUint(data1);

    Value data2Val(Type::kNumberType);
    data2Val.SetUint(data2);

    params.AddMember("generator", generatorIdVal, allocator);

    Value message(Type::kArrayType);

    message.PushBack(statusVal, allocator);
    message.PushBack(data1Val, allocator);
    message.PushBack(data2Val, allocator);

    params.AddMember("message", message, allocator);

    json.AddMember("params", params, allocator);

    write(json);
}
