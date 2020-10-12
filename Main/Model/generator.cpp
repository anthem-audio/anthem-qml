#include "generator.h"

Generator::Generator(ModelItem* parent, IdGenerator* id, QString generatorType,
                     QString displayName, QColor color) : ModelItem(parent, generatorType)
{
    this->id = id;
    this->displayName = displayName;
    this->color = color;
}

Generator::Generator(ModelItem* parent, IdGenerator* id, QString generatorType,
          QJsonObject& node) : ModelItem(parent, generatorType)
{
    throw "Not implemented.";
}

void Generator::serialize(QJsonObject& node) const {
    node["display_name"] = this->displayName;
    node["color"] = this->color.name();
}

QString Generator::getDisplayName() {
    return this->displayName;
}

QColor Generator::getColor() {
    return this->color;
}
