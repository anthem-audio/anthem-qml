#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "Utilities/mousehelper.h"
#include "Presenter/mainpresenter.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<MouseHelper>("io.github.anthem.utilities.mousehelper", 1, 0, "MouseHelper");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    MainPresenter mainPresenter(nullptr);
    engine.rootContext()->setContextProperty("Anthem", &mainPresenter);

    return app.exec();
}
