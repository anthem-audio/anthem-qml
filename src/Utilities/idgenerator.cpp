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

#include "idgenerator.h"

#include <QSysInfo>
#include <QByteArray>

IdGenerator::IdGenerator() {
    // Note:

    // These two IDs can be between 0 and 31. This makes
    // the total combinations equal to 1024.

    // If there are multiple ID generators for a single
    // project (i.e. if we add network collaboration),
    // these numbers must be coordinated such that at
    // least one of them is different between the two
    // generators.
    int intDatacenterId = 0;
    int intSystemId = 0;

    QSysInfo sysInfo = QSysInfo();
    QByteArray arr = sysInfo.machineUniqueId();

    for (int i = 0; i < arr.size(); i++) {
        if (i % 2 == 0)
            intDatacenterId ^= arr.at(i);
        else
            intSystemId ^= arr.at(i);
    }

    intDatacenterId %= SnowFlake::max_datacenter_num_;
    intSystemId %= SnowFlake::max_machine_num_;

    this->snowflake =
        new SnowFlake(intDatacenterId, intSystemId);
}

IdGenerator::~IdGenerator() {
    delete this->snowflake;
}

quint64 IdGenerator::get() {
    return snowflake->nextId();
}
