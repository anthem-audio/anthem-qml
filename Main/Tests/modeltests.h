#ifndef MODELTESTS_H
#define MODELTESTS_H

#include <QObject>
#include <QDebug>
#include <QtTest/QtTest>

#include "Presenter/mainpresenter.h"

class ModelTests : public QObject {
Q_OBJECT

private:
    bool myCondition() {
        return true;
    }

private slots:
    void initTestCase() {
        qDebug("Called before everything else.");
    }

    void emptyProject() {
        IdGenerator* id = new IdGenerator();
        MainPresenter* presenter = new MainPresenter(this, id);

        Project* project = presenter->getProjectAt(0);

        qDebug() << "Initial project state";
        QCOMPARE(project->transport->masterPitch->get(), 0.0f);

        qDebug() << "Direct item set";
        project->transport->masterPitch->set(10.0f, true);
        QCOMPARE(project->transport->masterPitch->get(), 10.0f);
    }

    void mySecondTest() {
        QVERIFY(myCondition());
    }

    void cleanupTestCase() {
        qDebug("Called after myFirstTest and mySecondTest.");
    }
};

#endif // MODELTESTS_H
