/*
 * Copyright © 2019 Andrew Penkrat <contact.aldrog@gmail.com>
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
 * along with TwitchTube.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import QTwitch.Api 0.1
import QTwitch.Models 0.1

Page {
    id: page
    allowedOrientations: Orientation.All

    Component.onCompleted: mainWindow.showCategories = false
    Component.onDestruction: mainWindow.showCategories = true

    InterfaceConfiguration {
        id: config
    }

    UserInfo {
        id: user
        self: true
    }

    Column {
        id: content
        width: parent.width

        PageHeader {
            id: header
            title: qsTr("Settings")
        }

        ValueButton {
            id: login

            property bool loggedIn: Client.authorization.status === Authorization.Authorized

            width: parent.width
            label: loggedIn ? qsTr("Log out") : qsTr("Sign in")
            value: loggedIn ? qsTr("Logged in as %1").arg(user.display) : ""

            onClicked: {
                if(loggedIn)
                    Client.authorization.erase()
                else
                    pageStack.push(Qt.resolvedUrl("LoginPage.qml"))
            }
        }

        TextSwitch {
            id: streamTitles

            text: qsTr("Show stream titles")
            checked: config.showStreamTitles
            onCheckedChanged: config.showStreamTitles = checked
        }

        TextSwitch {
            id: chatConnection

            text: qsTr("Automatically connect to chat")
            checked: config.connectToChat
            onCheckedChanged: config.connectToChat = checked
        }
    }
}
