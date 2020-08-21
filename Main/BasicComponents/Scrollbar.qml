/*
    Copyright (C) 2020 Joshua Wade

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

import QtQuick 2.15

Item {
    id: scrollbar

    enum Direction {
        Horizontal,
        Vertical
    }

    property int direction: width > height ? Scrollbar.Direction.Horizontal : Scrollbar.Direction.Vertical
    property bool hasResizeHandles: false

    property double scrollAreaSize: 100
    property double start: 0
    property double end: 40
    property double tick: 20

    function clamp(num) {
        return num < 0 ? 0 : num > 1 ? 1 : num;
    }

    property double _start: clamp(start / scrollAreaSize) * _handleAreaSize
    property double _end: clamp(end / scrollAreaSize) * _handleAreaSize
    property double _length: _end - _start

    property bool _isHorizontal: direction === Scrollbar.Direction.Horizontal
    property double _scrollbarShortSize: _isHorizontal ? height : width
    property double _scrollbarLongSize: _isHorizontal ? width : height
    property double _handleAreaSize: _scrollbarLongSize - 2 * _scrollbarShortSize

    Button {
        id: back

        anchors {
            top: parent.top
            left: parent.left
        }

        width: _scrollbarShortSize
        height: _scrollbarShortSize

        imageSource: _isHorizontal ? '../Images/Triangle Arrow Left.svg' : 'Images/Triangle Arrow Up.svg'
        imageWidth: !_isHorizontal ? 0.4 * width : 0.3 * width
        imageHeight: _isHorizontal ? 0.4 * width : 0.3 * width

        onClicked: {
            start -= tick;
            end -= tick;

            if (start < 0) {
                const offset = -start;
                start += offset;
                end += offset;
            }
        }
    }

    Item {
        id: handleContainer
        anchors {
            top: _isHorizontal ? parent.top : back.bottom
            left: _isHorizontal ? back.right : parent.left
            right: _isHorizontal ? forward.left : parent.right
            bottom: _isHorizontal ? parent.bottom : forward.top
        }

        Button {
            id: handle
            x: _isHorizontal ? _start : 0
            y: _isHorizontal ? 0 : _start
            width: _isHorizontal ? scrollbar._length : scrollbar._scrollbarShortSize
            height: _isHorizontal ? scrollbar._scrollbarShortSize : scrollbar._length
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            propagateComposedEvents: true

            function handleChange(normalizedPos) {
                const width = oldEnd - oldStart;

                let newStart = oldStart + normalizedPos - mouseOffset;
                let newEnd = newStart + width;

                if (newStart < 0) {
                    const offset = -newStart;
                    newStart += offset;
                    newEnd += offset;
                }

                if (newEnd > 1) {
                    const offset = newEnd - 1;
                    newStart -= offset;
                    newEnd -= offset;
                }

                scrollbar.start = newStart * scrollAreaSize;
                scrollbar.end = newEnd * scrollAreaSize;
            }

            property double mouseOffset
            property double oldStart
            property double oldEnd

            onMouseXChanged: {
                if (_isHorizontal)
                    handleChange(mouse.x / handleContainer.width);
            }

            onMouseYChanged: {
                if (!_isHorizontal)
                    handleChange(mouse.y / handleContainer.height);
            }

            onPressed: {
                mouseOffset = _isHorizontal
                        ? mouseX / handleContainer.width
                        : mouseY / handleContainer.height;

                const startNorm = start / scrollAreaSize;
                const endNorm = end / scrollAreaSize;

                if (mouseOffset < startNorm || mouseOffset > endNorm) {
                    const oldwidth = (scrollbar.end - scrollbar.start) / scrollbar.scrollAreaSize;
                    oldStart = mouseOffset - oldwidth * 0.5;
                    oldEnd = mouseOffset + oldwidth * 0.5;
                }
                else {
                    oldStart = scrollbar.start / scrollbar.scrollAreaSize;
                    oldEnd = scrollbar.end / scrollbar.scrollAreaSize;
                }

                handle.isMouseDown = true;
            }

            onReleased: {
                handle.isMouseDown = false;
            }
        }
    }

    Button {
        id: forward

        anchors {
            bottom: parent.bottom
            right: parent.right
        }

        width: _scrollbarShortSize
        height: _scrollbarShortSize

        imageSource: _isHorizontal ? 'Images/Triangle Arrow Right.svg' : 'Images/Triangle Arrow Down.svg'
        imageWidth: !_isHorizontal ? 0.4 * width : 0.3 * width
        imageHeight: _isHorizontal ? 0.4 * width : 0.3 * width

        onClicked: {
            start += tick;
            end += tick;

            if (end > scrollAreaSize) {
                const offset = end - scrollAreaSize;
                end -= offset;
                start -= offset;
            }
        }
    }
}
