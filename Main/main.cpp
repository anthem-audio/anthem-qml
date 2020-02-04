/*
    Copyright (C) 2019 Joshua Wade

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

#define HIDE_CONSOLE (_MSC_VER && !__INTEL_COMPILER)
#if HIDE_CONSOLE
#include <windows.h>
#endif

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
#if HIDE_CONSOLE
    FreeConsole();
#endif
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<MouseHelper>("io.github.anthem.utilities.mousehelper",
                                 1, 0, "MouseHelper");

    QQmlApplicationEngine qmlEngine;

    IdGenerator idGen = IdGenerator();
    MainPresenter mainPresenter(nullptr, &idGen);

    // Set global references to Anthem APIs in QML
    qmlEngine.rootContext()->setContextProperty("Anthem", &mainPresenter);
    qmlEngine.rootContext()->setContextProperty("PatternPresenter",
                                                mainPresenter.getPatternPresenter());

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&qmlEngine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    qmlEngine.load(url);

    return app.exec();
}
