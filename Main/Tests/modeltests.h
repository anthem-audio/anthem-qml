/*
    Copyright (C) 2019, 2020 Joshua Wade

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

#ifndef MODELTESTS_H
#define MODELTESTS_H

#include <QObject>
#include <QDebug>
#include <QtTest/QtTest>

#include "Presenter/mainpresenter.h"

#include "Include/rapidjson/pointer.h"

Q_DECLARE_METATYPE(PatchFragment::PatchType);
Q_DECLARE_METATYPE(rapidjson::Value*);

class ModelTests : public QObject {
Q_OBJECT

private:
    IdGenerator* id;
    MainPresenter* presenter;
    Project* project;

    rapidjson::Document doc;

    rapidjson::Value basicAddValue;
    rapidjson::Value basicAddValueOld;
    rapidjson::Value basicRemoveValue;
    rapidjson::Value basicRemoveValueOld;
    rapidjson::Value basicReplaceValue;
    rapidjson::Value basicReplaceValueOld;
    rapidjson::Value basicCopyValue;
    rapidjson::Value basicCopyValueOld;
    rapidjson::Value basicMoveValue;
    rapidjson::Value basicMoveValueOld;

private slots:
    void initTestCase() {
        id = new IdGenerator();
        presenter = new MainPresenter(this, id);

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
        basicAddValueOld.SetNull();
        basicRemoveValue.SetNull();
        basicRemoveValueOld.SetString("init value");
        basicReplaceValue.SetString("replace");
        basicReplaceValueOld.SetString("init value");
        basicCopyValue.SetNull();
        basicCopyValueOld.SetNull();
        basicMoveValue.SetNull();
        basicMoveValueOld.SetNull();
    }

    void emptyProject() {
        qDebug() << "Initial project state";
        QCOMPARE(project->getTransport()->masterPitch->get(), 0.0f);



        qDebug() << "Direct item set";

        // Set the value to -5, but send a live update instead of a patch.
        project->getTransport()->masterPitch->set(-5.0f, false);

        // The control should report the newly set value.
        QCOMPARE(project->getTransport()->masterPitch->get(), -5.0f);



        // Set the value to 10, and send a patch (final value in a channge operation).
        project->getTransport()->masterPitch->set(10.0f, true);

        // The control should report the newly set value.
        QCOMPARE(project->getTransport()->masterPitch->get(), 10.0f);
    }

    void presenterTests() {
        qDebug() << "Remove the current testing project and open a new one";
        presenter->removeProjectAt(0);
        presenter->newProject();


        qDebug() << "The new project should not be marked as having unsaved changes";
        QCOMPARE(presenter->projectHasUnsavedChanges(0), false);

        qDebug() << "Performing an action should add an undo step";
        presenter->setMasterPitch(3, true);
        QCOMPARE(presenter->getMasterPitch(), 3);
        QCOMPARE(presenter->projectHasUnsavedChanges(0), true);
        QCOMPARE(presenter->isProjectSaved(0), false);


        qDebug() << "Creating a new project should work as expected";
        presenter->newProject();
        qDebug() << "Checking for two open projects.";
        presenter->getProjectAt(0);
        presenter->getProjectAt(1);
        presenter->getEngineAt(1);
        presenter->getProjectFileAt(1);
        QCOMPARE(presenter->activeProjectIndex, 1);
        QCOMPARE(presenter->projectHasUnsavedChanges(0), true);
        QCOMPARE(presenter->isProjectSaved(0), false);
        QCOMPARE(presenter->projectHasUnsavedChanges(1), false);
        QCOMPARE(presenter->isProjectSaved(1), false);

        qDebug() << "We should be able to switch tabs";
        presenter->setMasterPitch(6, true);
        presenter->setMasterPitch(7, true);

        presenter->switchActiveProject(0);
        QCOMPARE(presenter->activeProjectIndex, 0);
        presenter->setMasterPitch(6, true);
        presenter->setMasterPitch(7, true);
        QCOMPARE(presenter->getMasterPitch(), 7);

        qDebug() << "We should be able to close the first tab";
        presenter->closeProject(0);
        presenter->switchActiveProject(0);
        QCOMPARE(presenter->activeProjectIndex, 0);
        QCOMPARE(presenter->getMasterPitch(), 9);

        qDebug() << "Save and load should work as expected";
        auto path = QDir::currentPath() + "/test.anthem";
        qDebug() << path;
        presenter->setMasterPitch(10, true);
        presenter->saveActiveProjectAs(path);
        QCOMPARE(presenter->projectHasUnsavedChanges(0), false);
        QCOMPARE(presenter->isProjectSaved(0), true);
        presenter->loadProject(path);
        QCOMPARE(presenter->activeProjectIndex, 1);
        QCOMPARE(presenter->getMasterPitch(), 10);
        QCOMPARE(presenter->projectHasUnsavedChanges(1), false);
        QCOMPARE(presenter->isProjectSaved(1), true);
        QCOMPARE(presenter->getProjectAt(presenter->activeProjectIndex)->getSong()->getPatterns().keys().length(), 1);

        presenter->setMasterPitch(-12, true);
        QCOMPARE(presenter->projectHasUnsavedChanges(1), true);
        QCOMPARE(presenter->isProjectSaved(1), true);
        presenter->saveActiveProject();
        presenter->loadProject(path);
        QCOMPARE(presenter->activeProjectIndex, 2);
        QCOMPARE(presenter->getMasterPitch(), -12);
        QCOMPARE(presenter->projectHasUnsavedChanges(1), false);
        QCOMPARE(presenter->isProjectSaved(1), true);
        QCOMPARE(presenter->projectHasUnsavedChanges(2), false);
        QCOMPARE(presenter->isProjectSaved(2), true);
        presenter->closeProject(2);
        presenter->closeProject(1);
        presenter->closeProject(0);
        presenter->newProject();
        presenter->switchActiveProject(0);

        QCOMPARE(presenter->activeProjectIndex, 0);



        qDebug() << "There should be one pattern by default";
        PatternPresenter& patternPresenter = *presenter->getPatternPresenter();
        Song& song = *presenter->getProjectAt(presenter->activeProjectIndex)->getSong();
        QCOMPARE(song.getPatterns().keys().length(), 1);
        QCOMPARE(song.getPatterns()[song.getPatterns().keys()[0]]->getDisplayName(), QString("New pattern"));

        qDebug() << "Pattern delete should work";
        patternPresenter.removePattern(song.getPatterns().keys()[0]);
        QCOMPARE(song.getPatterns().keys().length(), 0);

        qDebug() << "Pattern create should work";
        patternPresenter.createPattern("Test 1", QColor("#FFFFFF"));
        QCOMPARE(song.getPatterns().keys().length(), 1);
        QCOMPARE(song.getPatterns()[song.getPatterns().keys()[0]]->getDisplayName(), QString("Test 1"));
        QCOMPARE(song.getPatterns()[song.getPatterns().keys()[0]]->getColor(), QColor("#FFFFFF"));
        patternPresenter.createPattern("Test 2", QColor("#FFFFFF"));
        QCOMPARE(song.getPatterns().keys().length(), 2);
        patternPresenter.createPattern("Test 3", QColor("#FFFFFF"));
        QCOMPARE(song.getPatterns().keys().length(), 3);
    }

    void cleanupTestCase() {
        auto path = QDir::currentPath() + "/test.anthem";
        QFile file(path);
        file.remove();
    }
};

#endif // MODELTESTS_H
