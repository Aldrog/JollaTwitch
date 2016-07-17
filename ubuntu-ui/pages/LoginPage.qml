/*
 * Copyright © 2015-2016 Andrew Penkrat
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

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Web 0.2

Page {
    id: page

    property bool needExit: false
    // Status for NavigationCover
    property string navStatus: qsTr("Settings")

    header: PageHeader {
        id: head
        title: qsTr("Log into Twitch account")
    }

    WebView {
        id: twitchLogin

        anchors {
            top: head.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        onUrlChanged: {
            var newurl = url.toString()
            if(newurl.indexOf("http://localhost") === 0) {
                var params = newurl.substring(newurl.lastIndexOf('/') + 1)
                if(params.indexOf("#access_token") >= 0) {
                    authToken.value = params.split('=')[1].split('&')[0]
                    mainWindow.userChanged()
                }
                pageStack.pop()
            }
        }

        onNavigationRequested: {
            var rurl = request.url.toString()
            console.log(request)
            console.log(rurl)
            console.log(url)
            if(rurl.indexOf("http://localhost") === 0) {
                var params = rurl.substring(rurl.lastIndexOf('/') + 1)
                if(params.indexOf("#access_token") >= 0) {
                    authToken.value = params.split('=')[1].split('&')[0]
                }
                if(status === PageStatus.Activating)
                    needExit = true
                else
                    pageStack.pop()
            }
            else
                request.action = WebView.AcceptRequest;
        }
        url: encodeURI("https://api.twitch.tv/kraken/oauth2/authorize?response_type=token&client_id=n57dx0ypqy48ogn1ac08buvoe13bnsu&redirect_uri=http://localhost&scope=user_read user_follows_edit chat_login")
    }

    //onStatusChanged: if(status === PageStatus.Active && needExit) pageStack.pop()
}
