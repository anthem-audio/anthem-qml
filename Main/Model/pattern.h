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

#ifndef PATTERN_H
#define PATTERN_H

#include <QObject>
#include <QHash>
#include <QString>
#include <QColor>
#include <QJsonObject>

#include "Core/modelitem.h"
#include "Utilities/idgenerator.h"

class Pattern : public ModelItem
{
    Q_OBJECT
private:
    IdGenerator* id;
    QString displayName;
    QColor color;
public:
    Pattern(ModelItem* parent, IdGenerator* id, QString displayName,
            QColor color);
    Pattern(ModelItem* parent, IdGenerator* id, QJsonObject& patternNode);

    void serialize(QJsonObject& node) override;

    QString getDisplayName();
    QColor getColor();

signals:

public slots:
};

#endif // PATTERN_H
