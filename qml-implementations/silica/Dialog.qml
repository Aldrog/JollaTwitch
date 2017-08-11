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
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property alias title: header.title
    property alias acceptText: header.acceptText
    property alias cancelText: header.cancelText
    default property alias data: pageContents.data

    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: rootFlickable
        anchors {
            fill: parent
        }

        contentHeight: pageContents.height + Theme.paddingLarge

        Column {
            id: pageContents
            width: dialog.width

            DialogHeader {
                id: header

                dialog: dialog
                acceptText: qsTr("Apply")
                cancelText: qsTr("Cancel")
            }
        }

        VerticalScrollDecorator { flickable: rootFlickable }
    }
}