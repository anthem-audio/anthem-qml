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

    }

    void emptyProject() {
        IdGenerator* id = new IdGenerator();
        MainPresenter* presenter = new MainPresenter(this, id);

        Project* project = presenter->getProjectAt(0);

        qDebug() << "Initial project state";
        QCOMPARE(project->transport->masterPitch->get(), 0.0f);

        qDebug() << "Direct item set";
        // Set the value to -5, but send a live update instead of a patch.
        project->transport->masterPitch->set(-5.0f, false);
        // The control should report the newly set value.
        QCOMPARE(project->transport->masterPitch->get(), -5.0f);
        // The JSON model should not have been updated.
        QCOMPARE(project->transport->masterPitch->jsonNode->operator[]("initial_value").GetFloat(), 0.0f);

        // Set the value to 10, and send a patch (final value in a channge operation).
        project->transport->masterPitch->set(10.0f, true);
        // The control should report the newly set value.
        QCOMPARE(project->transport->masterPitch->get(), 10.0f);
        // The JSON model should be updated this time.
        QCOMPARE(project->transport->masterPitch->jsonNode->operator[]("initial_value").GetFloat(), 10.0f);
    }

    void mySecondTest() {
        QVERIFY(myCondition());
    }

    void cleanupTestCase() {

    }
};

#endif // MODELTESTS_H
