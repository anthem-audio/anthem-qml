#ifndef IDGENERATOR_H
#define IDGENERATOR_H

#include "Include/snowflake.h"

class IdGenerator
{
    SnowFlake* snowflake;
public:
    IdGenerator();
    ~IdGenerator();
    uint64_t get();
};

#endif // IDGENERATOR_H
