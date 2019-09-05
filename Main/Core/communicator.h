#ifndef COMMUNICATOR_H
#define COMMUNICATOR_H

#include <QObject>

class Communicator : public QObject
{
public:
    explicit Communicator(QObject* parent);
};

#endif // COMMUNICATOR_H
