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
import QtQuick.Window 2.15

// There are (number of groups - 1) * 2 spacers. Each time the control
// panel's width increases by 1 pixel, a pixel is added to one of the
// spacers, starting on the left and going to the right. This process
// is used to keep pixel-perfect icons, since the spacers all have
// integer pixel values.
//
// This process also corrects for pixel density.
Item {
    property int spacerNumber

    width:
        groupContainer.spacingBase +
        (((paddingItem.width - controlsPanel.spacerMargins)
            * Screen.devicePixelRatio) %
            groupContainer.spacerCount >=
        spacerNumber
            ? 1 / Screen.devicePixelRatio
            : 0)
    height: 1
}
