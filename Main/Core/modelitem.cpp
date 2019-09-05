#include "modelitem.h"

ModelItem::ModelItem(Communicator* parent) : Communicator(static_cast<QObject*>(parent))
{
    this->parent = parent;
}

ModelItem::~ModelItem() {}
