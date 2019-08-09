#ifndef MAINPRESENTER_H
#define MAINPRESENTER_H

#include <QObject>
#include <QString>

#include "../Model/project.h"

class MainPresenter : public QObject
{
    Q_OBJECT
public:
    explicit MainPresenter(QObject *parent = nullptr);

signals:

public slots:
    void loadProject(QString path);
};

#endif // MAINPRESENTER_H
