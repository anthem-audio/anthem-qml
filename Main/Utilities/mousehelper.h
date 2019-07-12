#ifndef MOUSEHELPER_H
#define MOUSEHELPER_H

#include <QObject>
#include <QCursor>

class MouseHelper : public QObject
{
    Q_OBJECT
public:
    explicit MouseHelper(QObject *parent = nullptr);

    Q_INVOKABLE void setCursorPosition(int x, int y);
    Q_INVOKABLE QPoint getCursorPosition();

signals:

public slots:
};

#endif // MOUSEHELPER_H
