/*
    Copyright (C) 2019 Joshua Wade

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
    IdGenerator* id;

public:
    Transport(ModelItem* parent, IdGenerator* id);
    Transport(ModelItem* parent, IdGenerator* id, rapidjson::Value& projectNode);
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
