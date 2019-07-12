#include "mousehelper.h"

MouseHelper::MouseHelper(QObject *parent) : QObject(parent)
{

}

void MouseHelper::setCursorPosition(int x, int y) {
    QCursor::setPos(x, y);
}

QPoint MouseHelper::getCursorPosition() {
    return QCursor::pos();
}
