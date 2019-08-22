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

    this->snowflake = new SnowFlake(intDatacenterId, intSystemId);
}

IdGenerator::~IdGenerator() {
    delete this->snowflake;
}

uint64_t IdGenerator::get() {
    return snowflake->nextId();
}
