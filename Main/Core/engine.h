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

// This class abstracts lifecycle and communication for
// the actual engine, which lives in a separate process.

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>
#include <QProcess>
#include <QJsonArray>
#include <QJsonObject>

class Engine : public QObject {
    Q_OBJECT
private:
    QProcess* engine;
    void addRPCHeaders(
        QJsonObject& json,
        QString method
    );
    void write(QJsonObject& json);

public:
    explicit
    Engine(QObject *parent);
    ~Engine();

    void start();
    void stop();

    void sendLiveControlUpdate(
        quint64 controlId, float value
    );
    void sendMidiNoteEvent(
        quint64 generatorId,
        quint8 status,
        quint8 data1,
        quint8 data2
    );
    // TODO: Add play, pause, stop, seek, etc.

    void sendPatch(
        QString operation,
        QString from,
        QString path,
        QJsonObject& value
    );
    void sendPatchList(QJsonArray& patchList);

signals:
    void engineStarted();

public slots:
    void onEngineStart();
    void onEngineMessageChunk();
};

#endif // ENGINE_H
