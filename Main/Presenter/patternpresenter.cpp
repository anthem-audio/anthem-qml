#include "patternpresenter.h"
#include <QDebug>

PatternPresenter::PatternPresenter(QObject* parent, IdGenerator* id, Project* activeProject) : QObject(parent) {
    this->id = id;
    this->activeProject = activeProject;
}

void PatternPresenter::setActiveProject(Project* project) {
    this->activeProject = project;
}
