/*
 * Copyright © 2017 Andrew Penkrat
 *
 * This file is part of TwitchTube.
 *
 * TwitchTube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * TwitchTube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with TwitchTube.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0

BackgroundItem {
    property string iconName

    height: parent.height
    width: height

    Image {
        id: heart
        anchors.fill: parent
        source: "images/" + iconName + ".png"
        visible: false
    }

    ColorOverlay {
        id: heartColor

        function overlayColor(color) {
            return Qt.rgba(color.r, color.g, color.b, color.a - Math.min(color.r, color.g, color.b))
        }

        anchors.fill: heart
        source: heart
        color: switchFollow.highlighted ? overlayColor(Theme.highlightColor) : overlayColor(Theme.primaryColor)
    }
}