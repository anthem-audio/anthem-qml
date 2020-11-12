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

#ifndef PATTERNPRESENTER_H
#define PATTERNPRESENTER_H

#include <QObject>
#include <QString>
#include <QColor>
#include <QVariant>

#include "Utilities/idgenerator.h"
#include "Model/project.h"

class PatternPresenter : public QObject {
    Q_OBJECT
private:
    IdGenerator* id;
    Project* activeProject;

    /// Pattern currently open in the pattern editor
    Pattern* activePattern;

    Pattern* getPattern(QString id);
public:
    explicit PatternPresenter(
        QObject* parent,
        IdGenerator* id,
        Project* activeProject
    );

    void setActiveProject(Project* project);

private slots:
    void activeProjectDestroyed();
    void activePatternDestroyed();
public slots:
    void setActivePattern(Pattern* pattern);
    QString createPattern(QString name, QColor color);
    void createPattern(QString id, QString name, QColor color);
    void removePattern(QString id);

    QString getPatternName(QString id);
    QColor getPatternColor(QString id);
};

#endif // PATTERNPRESENTER_H
