/*
    Copyright (C) 2019, 2020 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

#include "engine.h"

#include <QDebug>
#include <QJsonDocument>
#include <QJsonValue>

Engine::Engine(QObject* parent) : QObject(parent) {
    engine = new QProcess(this);
    QObject::connect(engine, &QProcess::started,
                     this,   &Engine::onEngineStart);
    QObject::connect(engine, &QProcess::readyRead,
                     this,   &Engine::onEngineMessageChunk);
    engine->setReadChannel(
        QProcess::ProcessChannel::StandardOutput
    );
    engine->setProcessChannelMode(
        QProcess::ProcessChannelMode::MergedChannels
    );
}

Engine::~Engine() {
    stop();
}

// TODO: propagate errors to user
void Engine::start() {
    engine->start("mock-engine", QStringList());
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

void Engine::write(QJsonObject& json) {
    QJsonDocument document(json);
    engine->write(document.toJson());
    engine->write("\n");
}

void Engine::addRPCHeaders(QJsonObject& json, QString method) {
    json["jsonrpc"] = "2.0";
    json["method"] = method;
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
void Engine::sendLiveControlUpdate(
    quint64 controlId, float value
) {
    QJsonObject json;

    addRPCHeaders(json, "ControlUpdate");

    QJsonObject params;

    QJsonValue controlIdVal(QString::number(controlId));
    QJsonValue valueVal(static_cast<double>(value));

    params["control_id"] = controlIdVal;
    params["value"] = valueVal;

    json["params"] = params;

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
void Engine::sendMidiNoteEvent(
    quint64 generatorId,
    quint8 status,
    quint8 data1,
    quint8 data2
) {
    QJsonObject json;

    addRPCHeaders(json, "MidiNoteEvent");

    QJsonObject params;

    QJsonValue generatorIdVal(QString::number(generatorId));
    QJsonValue statusVal(status);
    QJsonValue data1Val(data1);
    QJsonValue data2Val(data2);

    params["generator"] = generatorIdVal;

    QJsonArray message;

    message.push_back(statusVal);
    message.push_back(data1Val);
    message.push_back(data2Val);

    params["message"] = message;

    json["params"] = params;

    write(json);
}

void Engine::sendPatch(
    QString operation,
    QString from,
    QString path,
    QJsonObject& value
) {
    QJsonObject json;
    addRPCHeaders(json, "Patch");

    QJsonObject params;
    QJsonObject payload;

    payload["op"] = operation;

    if (!from.isNull() && !from.isEmpty()) {
        payload["from"] = from;
    }

    payload["path"] = path;

//    if (!value.isNull()) {
    payload["value"] = value;
//    }

    params["payload"] = payload;
    json["params"] = params;

    write(json);
}

void Engine::sendPatchList(QJsonArray& patchList) {
    QJsonObject json;
    addRPCHeaders(json, "Patch");

    QJsonObject params;
    params["payload"] = patchList;
    json["params"] = params;

    write(json);
}
