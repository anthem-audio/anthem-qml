#include "instrument.h"

Instrument::Instrument(ModelItem* parent, IdGenerator* id,
                       QString displayName, QColor color)
    : Generator(parent, id, "instrument", displayName, color)
{

}

Instrument::Instrument(ModelItem* parent, IdGenerator* id, QJsonObject& node)
    : Generator(parent, id, "instrument", node)
{

}

void Instrument::serialize(QJsonObject& node) const {
    Generator::serialize(node);
}
