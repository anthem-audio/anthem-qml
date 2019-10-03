#ifndef MODELTESTS_H
#define MODELTESTS_H

#include <QObject>
#include <QDebug>
#include <QtTest/QtTest>

#include "Presenter/mainpresenter.h"

#include "Include/rapidjson/pointer.h"

Q_DECLARE_METATYPE(PatchFragment::PatchType);
Q_DECLARE_METATYPE(rapidjson::Value*);

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
    IdGenerator* id;
    MainPresenter* presenter;
    PresenterEventCounter* eventCounter;
    Project* project;

    rapidjson::Document doc;

    rapidjson::Value basicAddValue;
    rapidjson::Value basicRemoveValue;
    rapidjson::Value basicReplaceValue;
    rapidjson::Value basicCopyValue;
    rapidjson::Value basicMoveValue;

private slots:
    void initTestCase() {
        id = new IdGenerator();
        presenter = new MainPresenter(this, id);

        eventCounter = new PresenterEventCounter(this);

        QObject::connect(presenter,    SIGNAL(masterPitchChanged(int)),
                         eventCounter, SLOT(masterPitchChanged(int)));

        project = presenter->getProjectAt(0);

        doc.Parse(
            "{"
            "    \"basic_remove\": \"init value\","
            "    \"basic_replace\": \"init value\","
            "    \"basic_copy_source\": \"init value\","
            "    \"basic_move_source\": \"init value\""
            "}"
        );

        basicAddValue.SetString("add");
        basicRemoveValue.SetNull();
        basicReplaceValue.SetString("replace");
        basicCopyValue.SetNull();
        basicRemoveValue.SetNull();
    }

    void emptyProject() {
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

    void patch_data() {
        // Note: a document is defined in initTestCase()
        // that will be used for each of the tests below.

        QTest::addColumn<PatchFragment::PatchType>("patchType");
        QTest::addColumn<QString>("from");
        QTest::addColumn<QString>("path");
        QTest::addColumn<rapidjson::Value*>("value");

        QTest::addRow("basic add")         << PatchFragment::PatchType::ADD      << QString()            << "/basic_add"              << &basicAddValue;
        QTest::addRow("basic remove")      << PatchFragment::PatchType::REMOVE   << QString()            << "/basic_remove"           << &basicRemoveValue;
        QTest::addRow("basic replace")     << PatchFragment::PatchType::REPLACE  << QString()            << "/basic_replace"          << &basicReplaceValue;
        QTest::addRow("basic copy")        << PatchFragment::PatchType::COPY     << "/basic_copy_source" << "/basic_copy_destination" << &basicCopyValue;
        QTest::addRow("basic move")        << PatchFragment::PatchType::MOVE     << "/basic_move_source" << "/basic_move_destination" << &basicMoveValue;
    }

    void patch() {
        QFETCH(PatchFragment::PatchType, patchType);
        QFETCH(QString, from);
        QFETCH(QString, path);
        QFETCH(rapidjson::Value*, value);

        rapidjson::Document startDoc;
        startDoc.CopyFrom(doc, startDoc.GetAllocator());

        Patch patch(this, presenter->getProjectAt(0), doc);
        switch (patchType) {
        case PatchFragment::PatchType::ADD:
            patch.patchAdd(path, *value);
            break;
        case PatchFragment::PatchType::REMOVE:
            patch.patchRemove(path);
            break;
        case PatchFragment::PatchType::REPLACE:
            patch.patchReplace(path, *value);
            break;
        case PatchFragment::PatchType::COPY:
            patch.patchCopy(from, path);
            break;
        case PatchFragment::PatchType::MOVE:
            patch.patchMove(from, path);
            break;
        }

        patch.apply();

        rapidjson::Document afterPatchDoc;
        afterPatchDoc.CopyFrom(doc, afterPatchDoc.GetAllocator());

        switch (patchType) {
        case PatchFragment::PatchType::ADD:
            QCOMPARE(rapidjson::Pointer(path.toStdString()).Get(afterPatchDoc)->GetString(), "add");
            break;
        case PatchFragment::PatchType::REMOVE:
            QVERIFY(rapidjson::Pointer(path.toStdString()).GetWithDefault(afterPatchDoc, rapidjson::kNullType).IsNull());
            break;
        case PatchFragment::PatchType::REPLACE:
            QCOMPARE(rapidjson::Pointer(path.toStdString()).Get(afterPatchDoc)->GetString(), "replace");
            break;
        case PatchFragment::PatchType::COPY:
            QCOMPARE(rapidjson::Pointer(from.toStdString()).Get(afterPatchDoc)->GetString(),
                     rapidjson::Pointer(path.toStdString()).Get(afterPatchDoc)->GetString());
            break;
        case PatchFragment::PatchType::MOVE:
            QCOMPARE(rapidjson::Pointer(from.toStdString()).Get(startDoc)->GetString(),
                     rapidjson::Pointer(path.toStdString()).Get(afterPatchDoc)->GetString());
            QVERIFY(rapidjson::Pointer(from.toStdString()).GetWithDefault(afterPatchDoc, rapidjson::kNullType).IsNull());
            break;
        }

        patch.applyUndo();

        rapidjson::Document afterUndoDoc;
        afterUndoDoc.CopyFrom(doc, afterUndoDoc.GetAllocator());

        switch (patchType) {
        case PatchFragment::PatchType::ADD:
            QVERIFY(rapidjson::Pointer(path.toStdString()).GetWithDefault(afterUndoDoc, rapidjson::kNullType).IsNull());
            break;
        case PatchFragment::PatchType::REMOVE:
            QCOMPARE(rapidjson::Pointer(path.toStdString()).Get(afterUndoDoc)->GetString(),
                     rapidjson::Pointer(path.toStdString()).Get(startDoc)->GetString());
            break;
        case PatchFragment::PatchType::REPLACE:
            QCOMPARE(rapidjson::Pointer(path.toStdString()).Get(afterUndoDoc)->GetString(),
                     rapidjson::Pointer(path.toStdString()).Get(startDoc)->GetString());
            QVERIFY(rapidjson::Pointer(path.toStdString()).Get(afterUndoDoc)->GetString() !=
                    rapidjson::Pointer(path.toStdString()).Get(afterPatchDoc)->GetString());
            break;
        case PatchFragment::PatchType::COPY:
            QCOMPARE(rapidjson::Pointer(from.toStdString()).Get(afterUndoDoc)->GetString(),
                     rapidjson::Pointer(from.toStdString()).Get(startDoc)->GetString());
            QVERIFY(rapidjson::Pointer(path.toStdString()).GetWithDefault(afterUndoDoc, rapidjson::kNullType).IsNull());
            break;
        case PatchFragment::PatchType::MOVE:
            QCOMPARE(rapidjson::Pointer(from.toStdString()).Get(afterUndoDoc)->GetString(),
                     rapidjson::Pointer(from.toStdString()).Get(startDoc)->GetString());
            QVERIFY(rapidjson::Pointer(path.toStdString()).GetWithDefault(afterUndoDoc, rapidjson::kNullType).IsNull());
            break;
        }
    }

    void cleanupTestCase() {

    }
};

#endif // MODELTESTS_H
