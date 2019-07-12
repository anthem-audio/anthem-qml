#include "mousehelper.h"
#include <QGuiApplication>

MouseHelper::MouseHelper(QObject *parent) : QObject(parent)
{

}

void MouseHelper::setCursorPosition(int x, int y) {
    QCursor::setPos(x, y);
}

QPoint MouseHelper::getCursorPosition() {
    return QCursor::pos();
}

void MouseHelper::setCursorToBlank() {
    QGuiApplication::setOverrideCursor(QCursor(Qt::BlankCursor));
}

void MouseHelper::setCursorToArrow() {
    QGuiApplication::setOverrideCursor(QCursor(Qt::ArrowCursor));
}
