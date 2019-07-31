#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>
#include "../Core/modelitem.h"

class Project : public QObject, ModelItem
{
    Q_OBJECT
public:
    explicit Project(QObject *parent = nullptr);

signals:

public slots:
};

#endif // PROJECT_H
