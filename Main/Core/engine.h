// This class abstracts lifecycle and communication for
// the actual engine, which lives in a separate process.

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>
#include <QProcess>

#include "Include/rapidjson/document.h"
#include "Include/rapidjson/stringbuffer.h"
#include "Include/rapidjson/writer.h"

class Engine : public QObject
{
    Q_OBJECT
private:
    QProcess* engine;
    void addRPCHeaders(rapidjson::Document& json, std::string headers);
    void write(rapidjson::Document& json);

public:
    explicit
    Engine(QObject *parent);

    void start();
    void stop();

    void sendLiveControlUpdate(uint64_t controlId, float value);
    void sendMidiNoteEvent(uint64_t generatorId, uint8_t status, uint8_t data1, uint8_t data2);
    // TODO: Add play, pause, stop, seek, etc.

    void sendPatch(QString operation, QString from, QString path, rapidjson::Value &value);

signals:
    void engineStarted();

public slots:
    void onEngineStart();
    void onEngineMessageChunk();
};

#endif // ENGINE_H
