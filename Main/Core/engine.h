// This class abstracts lifecycle and communication for
// the actual engine, which lives in a separate process.

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>
#include <QProcess>

class Engine : public QObject
{
    Q_OBJECT
private:
    QProcess* engine;

public:
    explicit
    Engine(QObject *parent);

    void start();
    void stop();

    void sendLiveControlUpdate(uint64_t controlId, float value);
    void sendPatch();

signals:

public slots:
    void onEngineStart();
    void onEngineMessageChunk();
};

#endif // ENGINE_H
