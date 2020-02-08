/*
    Copyright (C) 2020 Joshua Wade

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

#include "patternpresenter.h"
#include <QDebug>

PatternPresenter::PatternPresenter(QObject* parent, IdGenerator* id,
                                   Project* activeProject)
                                    : QObject(parent) {
    this->id = id;
    this->activeProject = activeProject;
    connectUiUpdateSignals(activeProject);
}

void PatternPresenter::connectUiUpdateSignals(Project* project) {
    QObject::connect(project->getSong(),    SIGNAL(patternAdd(QString)),
                     this,                  SLOT(ui_addPattern(QString)));
    QObject::connect(project->getSong(),    SIGNAL(patternRemove(QString)),
                     this,                  SLOT(ui_removePattern(QString)));
}

void PatternPresenter::disconnectUiUpdateSignals(Project* project) {
    QObject::disconnect(project->getSong(), SIGNAL(patternAdd(QString)),
                     this,                  SLOT(ui_addPattern(QString)));
    QObject::disconnect(project->getSong(), SIGNAL(patternRemove(QString)),
                     this,                  SLOT(ui_removePattern(QString)));
}

void PatternPresenter::emitAllChangeSignals() {
    auto patterns = activeProject->getSong()->getPatterns();
    QVariantMap uiPatternMap;

    for (auto key : patterns.keys()) {
        Pattern* pattern = patterns[key];
        QVariantMap patternInfo;

        patternInfo.insert("displayName", pattern->getDisplayName());
        patternInfo.insert("color", pattern->getColor());

        uiPatternMap.insert(key, patternInfo);
    }

    emit flushPatterns(uiPatternMap);
}

void PatternPresenter::setActiveProject(Project* project) {
    disconnectUiUpdateSignals(this->activeProject);
    this->activeProject = project;
    this->activePattern = nullptr; // TODO: preserve active pattern
    connectUiUpdateSignals(this->activeProject);
    emitAllChangeSignals();
}

void PatternPresenter::setActivePattern(Pattern* pattern) {
    this->activePattern = pattern;
}

void PatternPresenter::createPattern(QString name, QColor color) {
    activeProject->getSong()->addPattern(name, color);
}


Pattern* PatternPresenter::getPattern(QString id) {
    return this->activeProject->getSong()->getPattern(id);
}

QString PatternPresenter::getPatternName(QString id) {
    return this->getPattern(id)->getDisplayName();
}

QColor PatternPresenter::getPatternColor(QString id) {
    return this->getPattern(id)->getColor();
}


void PatternPresenter::ui_addPattern(QString id) {
    emit patternAdd(id);
}

void PatternPresenter::ui_removePattern(QString id) {
    emit patternRemove(id);
}
