#ifndef GENERATOR_H
#define GENERATOR_H

#include <QObject>
#include <QString>
#include <QColor>

#include "Core/modelitem.h"
#include "Utilities/idgenerator.h"

class Generator : public ModelItem
{
    Q_OBJECT
private:
    IdGenerator* id;
    QString displayName;
    QColor color;
public:
    Generator(ModelItem* parent, IdGenerator* id, QString generatorType,
              QString displayName, QColor color);
    Generator(ModelItem* parent, IdGenerator* id, QString generatorType,
              QJsonObject& node);

    void serialize(QJsonObject& node) const override;

    QString getDisplayName();
    QColor getColor();
};

#endif // GENERATOR_H
