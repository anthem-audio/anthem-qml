/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

#include "engine.h"

#include <QDebug>

using namespace rapidjson;

Engine::Engine(QObject* parent) : QObject(parent) {
    engine = new QProcess(this);
    QObject::connect(engine, &QProcess::started,
                     this,   &Engine::onEngineStart);
    QObject::connect(engine, &QProcess::readyRead,
                     this,   &Engine::onEngineMessageChunk);
    engine->setReadChannel(QProcess::ProcessChannel::StandardOutput);
    engine->setProcessChannelMode(QProcess::ProcessChannelMode::MergedChannels);
}

Engine::~Engine() {
    stop();
}

// TODO: propagate errors to user
void Engine::start() {
    engine->start("mock-engine");
}

// TODO: propagate errors to user
// TODO: don't just kill; tell the engine process to stop, and let it stop itself
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
    engine->write("\n");
}

void Engine::addRPCHeaders(Document &json, std::string method) {
    Value jsonrpcVal(Type::kStringType);
    jsonrpcVal.SetString("2.0");
    json.AddMember("jsonrpc", jsonrpcVal, json.GetAllocator());

    Value methodVal(Type::kStringType);
    methodVal.SetString(method, json.GetAllocator());
    json.AddMember("method", methodVal, json.GetAllocator());
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

    addRPCHeaders(json, "ControlUpdate");

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

    addRPCHeaders(json, "MidiNoteEvent");

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

void Engine::sendPatch(QString operation, QString from, QString path, Value& value) {
    Document json;
    json.SetObject();
    Document::AllocatorType& allocator = json.GetAllocator();
    addRPCHeaders(json, "Patch");

    Value params(Type::kObjectType);
    Value payload(Type::kObjectType);

    Value operationVal(Type::kStringType);
    operationVal.SetString(operation.toStdString(), allocator);
    payload.AddMember("op", operationVal, allocator);

    if (!from.isNull() && !from.isEmpty()) {
        Value fromVal(Type::kStringType);
        fromVal.SetString(from.toStdString(), allocator);
        payload.AddMember("from", fromVal, allocator);
    }

    Value pathVal(Type::kStringType);
    pathVal.SetString(path.toStdString(), allocator);
    payload.AddMember("path", pathVal, allocator);

    if (!value.IsNull()) {
        payload.AddMember("value", value, allocator);
    }

    params.AddMember("payload", payload, allocator);
    json.AddMember("params", params, allocator);

    write(json);
}

void Engine::sendPatchList(rapidjson::Value& patchList) {
    Document json;
    json.SetObject();
    Document::AllocatorType& allocator = json.GetAllocator();
    addRPCHeaders(json, "Patch");

    Value params(Type::kObjectType);
    params.AddMember("payload", patchList, allocator);
    json.AddMember("params", params, allocator);

    write(json);
}
