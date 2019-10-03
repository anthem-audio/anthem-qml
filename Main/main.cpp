#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>

#include "Utilities/mousehelper.h"
#include "Utilities/idgenerator.h"
#include "Presenter/mainpresenter.h"

#include "Tests/modeltests.h"

int main(int argc, char *argv[]) {
    // Simplistic check for -test or --test in first argument position
    if (argc > 1 && (strncmp(argv[1], "-test", 6) == 0 || strncmp(argv[1], "--test", 7) == 0)) {
        ModelTests modelTests;
        return QTest::qExec(&modelTests);
    }
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<MouseHelper>("io.github.anthem.utilities.mousehelper", 1, 0, "MouseHelper");

    QQmlApplicationEngine engine;

    IdGenerator idGen = IdGenerator();
    MainPresenter mainPresenter(nullptr, &idGen);
    engine.rootContext()->setContextProperty("Anthem", &mainPresenter);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
