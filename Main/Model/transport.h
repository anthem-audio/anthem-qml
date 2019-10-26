#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/modelitem.h"
#include "Model/control.h"

class Transport : public ModelItem {
    Q_OBJECT
private:
    quint8 defaultNumerator;
    quint8 defaultDenominator;

public:
    Transport(ModelItem* parent, rapidjson::Value& projectNode);
    void externalUpdate(QStringRef pointer, PatchFragment& patch) override;
    void serialize(rapidjson::Value& value, rapidjson::Document& doc) override;

    Control* masterPitch;
    Control* beatsPerMinute;

    void setNumerator(quint8 numerator);
    quint8 getNumerator();
    void setDenominator(quint8 denominator);
    quint8 getDenominator();

signals:
    void numeratorDisplayValueChanged(quint8 numerator);
    void denominatorDisplayValueChanged(quint8 denominator);

public slots:
};

#endif // TRANSPORT_H
