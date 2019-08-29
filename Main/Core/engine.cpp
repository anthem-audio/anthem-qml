#include "engine.h"

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
    engine->write("hi lol\n");
}

void Engine::onEngineMessageChunk() {

}
