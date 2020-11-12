#ifndef INSTRUMENT_H
#define INSTRUMENT_H

#include <QObject>
#include <QString>
#include <QColor>
#include <QJsonObject>

#include "generator.h"
#include "Core/modelitem.h"
#include "Utilities/idgenerator.h"

class Instrument : public Generator
{
    Q_OBJECT
public:
    Instrument(ModelItem* parent, IdGenerator* id, QString displayName, QColor color);
    Instrument(ModelItem* parent, IdGenerator* id, QJsonObject& patternNode);

    void serialize(QJsonObject& node) const override;
};

#endif // INSTRUMENT_H
