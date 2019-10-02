#ifndef MODELTESTS_H
#define MODELTESTS_H

#include <QObject>
#include <QDebug>
#include <QtTest/QtTest>

#include "Presenter/mainpresenter.h"

class PresenterEventCounter : public QObject {
Q_OBJECT

public:
    int masterPitchEventCount;
    int mostRecentMasterPitch;
    PresenterEventCounter(QObject* parent) : QObject(parent) {
        masterPitchEventCount = 0;
        mostRecentMasterPitch = 0;
    }
public slots:
    void masterPitchChanged(int pitch) {
        mostRecentMasterPitch = pitch;
        masterPitchEventCount++;
    }
};

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

        PresenterEventCounter* eventCounter = new PresenterEventCounter(this);

        QObject::connect(presenter,    SIGNAL(masterPitchChanged(int)),
                         eventCounter, SLOT(masterPitchChanged(int)));

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

        // The signal for updating the UI should not have fired because the change does
        // not represent a change to the model. Arguably it shouldn't fire at all, but
        // I've made the decision to update the UI on any final model change so I don't
        // need to distinguish between updates coming from the UI and upadtes coming
        // from undo and redo. This reasoning may not hold with models that are managing
        // a higher degree of complexity (as in, the extra update may be unwanted), but
        // for a single value it doesn't seem too bad. We'll see if I change my mind :)
        QCOMPARE(eventCounter->masterPitchEventCount, 0);



        // Set the value to 10, and send a patch (final value in a channge operation).
        project->transport->masterPitch->set(10.0f, true);

        // The control should report the newly set value.
        QCOMPARE(project->transport->masterPitch->get(), 10.0f);

        // The JSON model should be updated this time.
        QCOMPARE(project->transport->masterPitch->jsonNode->operator[]("initial_value").GetFloat(), 10.0f);

        // This is a final (patch-emitting) change, so the UI should have been notified
        // (see above)
        QCOMPARE(eventCounter->masterPitchEventCount, 1);
        QCOMPARE(eventCounter->mostRecentMasterPitch, 10);



        qDebug() << "Verify correct patch generation via undo history";

        // At this point there should be one patch for 0.0f -> 10.0f
        rapidjson::Value& patch = presenter->getProjectHistoryAt(0)[0]->getPatch();
        QCOMPARE(patch[0]["op"].GetString(), "replace");
        QCOMPARE(patch[0]["path"].GetString(), "/project/transport/master_pitch/initial_value");
        QCOMPARE(patch[0]["value"].GetFloat(), 10.0f);

        // ... and a corresponding undo patch for 10.0f -> 0.0f
        rapidjson::Value& undoPatch = presenter->getProjectHistoryAt(0)[0]->getUndoPatch();
        QCOMPARE(undoPatch[0]["op"].GetString(), "replace");
        QCOMPARE(undoPatch[0]["path"].GetString(), "/project/transport/master_pitch/initial_value");
        QCOMPARE(undoPatch[0]["value"].GetFloat(), 0.0f);
    }

    void mySecondTest() {
        QVERIFY(myCondition());
    }

    void cleanupTestCase() {

    }
};

#endif // MODELTESTS_H
