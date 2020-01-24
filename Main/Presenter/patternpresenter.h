#ifndef PATTERNPRESENTER_H
#define PATTERNPRESENTER_H

#include <QObject>

#include "Utilities/idgenerator.h"
#include "Model/project.h"

class PatternPresenter : public QObject {
    Q_OBJECT
private:
    IdGenerator* id;
    Project* activeProject;

    /// Pattern currently open in the pattern editor
    Pattern* activePattern;
public:
    explicit PatternPresenter(QObject* parent, IdGenerator* id, Project* activeProject);

    void setActiveProject(Project* project);
    void setActivePattern(Pattern* pattern);
};

#endif // PATTERNPRESENTER_H
