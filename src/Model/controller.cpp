#include "controller.h"

Controller::Controller(ModelItem* parent, IdGenerator* id,
                       QString displayName, QColor color)
    : Generator(parent, id, "controller", displayName, color)
{

}

Controller::Controller(ModelItem* parent, IdGenerator* id, QJsonObject& node)
    : Generator(parent, id, "controller", node)
{

}

void Controller::serialize(QJsonObject& node) const {
    Generator::serialize(node);
}
