/*
    Copyright (C) 2019, 2020 Joshua Wade

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

#include "transport.h"

Transport::Transport(
            ModelItem* parent, IdGenerator* id
        ) : ModelItem(parent, "transport")
{
    this->id = id;

    masterPitch =
        new Control(this, "master_pitch", *id, 0, -12, 12, 1);
    beatsPerMinute =
        new Control(this, "beats_per_minute", *id, 140, 10, 999, 0.01f);

    defaultNumerator = 4;
    defaultDenominator = 4;
}

Transport::Transport(
            ModelItem* parent,
            IdGenerator* id,
            QJsonObject& transportNode
        ) : ModelItem(parent, "transport")
{
    this->id = id;

    QJsonObject masterPitchNode =
            transportNode["master_pitch"].toObject();
    masterPitch =
            new Control(this, "master_pitch", masterPitchNode);

    QJsonObject beatsPerMinuteNode =
            transportNode["beats_per_minute"].toObject();
    beatsPerMinute =
            new Control(this, "beats_per_minute", beatsPerMinuteNode);

    defaultNumerator =
        static_cast<quint8>(transportNode["default_numerator"].toInt());

    defaultDenominator =
        static_cast<quint8>(transportNode["default_denominator"].toInt());
}

void Transport::serialize(QJsonObject& node) const {
    QJsonObject masterPitch;
    QJsonObject beatsPerMinute;

    this->masterPitch->serialize(masterPitch);
    this->beatsPerMinute->serialize(beatsPerMinute);

    node["master_pitch"] = masterPitch;
    node["beats_per_minute"] = beatsPerMinute;

    node["default_numerator"] = this->getNumerator();
    node["default_denominator"] = this->getDenominator();
}

void Transport::setNumerator(quint8 numerator) {
    defaultNumerator = numerator;
    QJsonValue v(numerator);
    patchReplace("default_numerator", v);
    sendPatch();
}

quint8 Transport::getNumerator() const {
    return defaultNumerator;
}

void Transport::setDenominator(quint8 denominator) {
    defaultDenominator = denominator;
    QJsonValue v(denominator);
    patchReplace("default_denominator", v);
    sendPatch();
}

quint8 Transport::getDenominator() const {
    return defaultDenominator;
}
