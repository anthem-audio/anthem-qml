/*
    Copyright (C) 2019 Joshua Wade

    This file is part of Anthem.

    Anthem is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Anthem is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Anthem. If not, see
                        <https://www.gnu.org/licenses/>.
*/

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
