#ifndef CONTROL_H
#define CONTROL_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/modelitem.h"

class Control : public ModelItem
{
    Q_OBJECT
private:
    uint64_t id;
    float initialValue;
    float minimum;
    float maximum;
    float step;
    // control symbol??
    // connection
    bool overrideAutomation;
public:
    // Derive information from existing JSON node
    Control(ModelItem *parent, rapidjson::Value* controlNode);

    // Generate new JSON node and add as field under parentNode
    // parentNode[controlName] = {...newly generated control...}
    Control(QObject *parent,
            rapidjson::Value* parentNode,
            std::string controlName,
            float minimum,
            float maximum,
            float initialValue,
            float step);

signals:

public slots:
};

#endif // CONTROL_H
