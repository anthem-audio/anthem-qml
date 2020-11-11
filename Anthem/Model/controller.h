#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QString>
#include <QColor>
#include <QJsonObject>

#include "generator.h"
#include "Core/modelitem.h"
#include "Utilities/idgenerator.h"

class Controller : public Generator
{
    Q_OBJECT
public:
    Controller(ModelItem* parent, IdGenerator* id, QString displayName, QColor color);
    Controller(ModelItem* parent, IdGenerator* id, QJsonObject& patternNode);

    void serialize(QJsonObject& node) const override;
};

#endif // CONTROLLER_H
