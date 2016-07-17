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

import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import harbour.twitchtube.ircchat 1.0
import "../js/httphelper.js" as HTTP

Page {
    id: page

    property var url
    property string channel
    property string username
    property bool followed
    property bool chatMode: false
    property bool audioMode: false
    property bool active: Qt.application.active
    property bool fullscreenConditions: isLandscape && main.visibleArea.yPosition === 0 && !main.moving && !state && video.visible

    function findUrl(s, q) {
        for (var x in s) {
            if (s[x].substring(0,4) === "http" && s[x].indexOf(q) >= 0)
                return s[x]
        }
    }

    function loadStreamInfo() {
        HTTP.getRequest("http://api.twitch.tv/api/channels/" + channel + "/access_token", function (tokendata) {
            if (tokendata) {
                var token = JSON.parse(tokendata)
                HTTP.getRequest(encodeURI("http://usher.twitch.tv/api/channel/hls/" + channel + ".json?allow_source=true&allow_audio_only=true&sig=" + token.sig + "&token=" + token.token + "&type=any"), function (data) {
                    if (data) {
                        var videourls = data.split('\n')
                        url = {
                            chunked: findUrl(videourls, "chunked"),
                            high: findUrl(videourls, "high"),
                            medium: findUrl(videourls, "medium"),
                            low: findUrl(videourls, "low"),
                            mobile: findUrl(videourls, "mobile"),
                            audio: findUrl(videourls, "audio_only")
                        }
                        video.play()
                        mainWindow.audioUrl = url.audio
                    }
                })
            }
        })
    }

    function checkFollow() {
        if(mainWindow.username) {
            HTTP.getRequest("https://api.twitch.tv/kraken/users/" + mainWindow.username + "/follows/channels/" + channel, function(data) {
                if(data)
                    return true
            })
        }
        return false
    }

    onChatModeChanged: {
        if(chatMode)
            video.stop()
    }

    allowedOrientations: Orientation.All

    onStatusChanged: {
        if(status === PageStatus.Activating) {
            mainWindow.currentChannel = channel
            mainWindow.cover = Qt.resolvedUrl("../cover/StreamCover.qml")
            cpptools.setBlankingMode(false)
        }
        if(status === PageStatus.Deactivating) {
            if (_navigation === PageNavigation.Back) {
                mainWindow.cover = Qt.resolvedUrl("../cover/NavigationCover.qml")
            }
            cpptools.setBlankingMode(true)
        }
    }

    onActiveChanged: {
        if(page.status === PageStatus.Active) {
            if(active) {
                mainWindow.stopAudio()
                video.play()
                if(!twitchChat.connected) {
                    twitchChat.reopenSocket()
                    twitchChat.join(channel)
                }
            }
            else {
                video.pause()
                if(audioMode)
                    mainWindow.playAudio()
                if(twitchChat.connected)
                    twitchChat.disconnect()
            }
        }
    }

    Component.onCompleted: {
        loadStreamInfo()
        followed = checkFollow()
    }

    Timer {
        id: fullscreenTimer

        interval: 3000
        running: fullscreenConditions
        onTriggered: page.state = "fullscreen"
    }

    SilicaFlickable {
        id: main

        anchors.fill: parent
        contentHeight: isPortrait ? page.height : (chatMode ? page.height : (5/3 * Screen.width))
        //onContentHeightChanged: console.log(contentHeight, height + Screen.width, Screen.width, chat.height)

        PullDownMenu {
            id: streamMenu

            MenuItem {
                text: qsTr("Follow")
                onClicked: HTTP.putRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                    if(data)
                        followed = true
                })
                visible: mainWindow.username && !followed
            }

            MenuItem {
                text: qsTr("Unfollow")
                onClicked: HTTP.deleteRequest("https://api.twitch.tv/kraken/users/" + username + "/follows/channels/" + channel + "?oauth_token=" + authToken.value, function(data) {
                    if(data === 204)
                        followed = false
                })
                visible: mainWindow.username && followed
            }

            MenuItem {
                text: qsTr("Quality")
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("QualityChooserPage.qml"), { chatOnly: chatMode, audioOnly: audioMode, channel: channel })
                    dialog.accepted.connect(function() {
                        chatMode = dialog.chatOnly
                        audioMode = dialog.audioOnly
                    })
                }
            }
        }

        Rectangle {
            id: videoBackground

            color: "black"
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: (!chatMode && !audioMode) ? (isPortrait ? screen.width * 9/16 : screen.width) : 0
            visible: (!chatMode && !audioMode)

            Video {
                id: video

                anchors.fill: parent
                source: audioMode ? url["audio"] : url[streamQuality.value]

                onErrorChanged: console.error("video error:", errorString)

                BusyIndicator {
                    anchors.centerIn: parent
                    running: video.playbackState !== MediaPlayer.PlayingState
                    size: isPortrait ? BusyIndicatorSize.Medium : BusyIndicatorSize.Large
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        page.state = !page.state ? "fullscreen" : ""
                        console.log(page.state)
                    }
                }
            }
        }

        TextField {
            id: chatMessage

            anchors {
                left: parent.left
                right: parent.right
                top: chatFlowBtT.value ? videoBackground.bottom : undefined
                bottom: chatFlowBtT.value ? undefined : parent.bottom
                topMargin: chatMode ? Theme.paddingLarge : Theme.paddingMedium
                bottomMargin: Theme.paddingMedium
            }
            // Maybe it's better to replace ternary operators with if else blocks
            placeholderText: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
            label: twitchChat.connected ? (twitchChat.anonymous ? qsTr("Please log in to send messages") : qsTr("Type your message here")) : qsTr("Chat is not available")
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.enabled: text.length > 0 && twitchChat.connected && !twitchChat.anonymous
            EnterKey.onClicked: {
                twitchChat.sendMessage(text)
                text = ""
            }
        }

        SilicaListView {
            id: chat

            anchors {
                left: parent.left
                right: parent.right
                top: chatFlowBtT.value ? chatMessage.bottom : videoBackground.bottom
                bottom: chatFlowBtT.value ? parent.bottom : chatMessage.top
                //topMargin: (chatMode && !chatFlowBtT.value) ? 0 : Theme.paddingMedium
                //bottomMargin: 0//chatFlowBtT.value ? Theme.paddingLarge : Theme.paddingMedium
            }

            highlightRangeMode: count > 0 ? ListView.StrictlyEnforceRange : ListView.NoHighlightRange
            //preferredHighlightBegin: chat.height - currentItem.height
            preferredHighlightEnd: chat.height
            clip: true
            verticalLayoutDirection: chatFlowBtT.value ? ListView.BottomToTop : ListView.TopToBottom

            model: twitchChat.messages
            delegate: Item {
                height: lbl.height
                width: chat.width

                ListView.onAdd: {
                    if(chat.currentIndex >= chat.count - 3) {
                        chat.currentIndex = chat.count - 1
                    }
                }

                Label {
                    id: lbl

                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }

                    text: richTextMessage
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    color: isNotice ? Theme.highlightColor : Theme.primaryColor
                }
            }

            IrcChat {
                id: twitchChat

                name: mainWindow.username
                password: 'oauth:' + authToken.value
                anonymous: !mainWindow.username
                textSize: Theme.fontSizeMedium

                Component.onCompleted: {
                    twitchChat.join(channel)
                }

                onErrorOccured: {
                    console.log("Chat error: ", errorDescription)
                }

                onConnectedChanged: {
                    console.log(connected)
                }
            }

            ViewPlaceholder {
                id: chatPlaceholder

                text: twitchChat.connected ? qsTr("Welcome to the chat room") : qsTr("Connecting to chat...")
                enabled: chat.count <= 0
                verticalOffset: -(chat.verticalLayoutDirection == ListView.TopToBottom ? (page.height - chat.height) / 2 : page.height - (page.height - chat.height) / 2)
            }

            VerticalScrollDecorator { flickable: chat }
        }
        //VerticalScrollDecorator { flickable: main }
    }

    states: State {
        name: "fullscreen"
        PropertyChanges {
            target: main
            contentHeight: page.height
        }

        PropertyChanges {
            target: chatMessage
            visible: false
        }

        PropertyChanges {
            target: chat
            visible: false
        }

        PropertyChanges {
            target: streamMenu
            visible: false
            active: false
        }

        PropertyChanges {
            target: page
            showNavigationIndicator: false; backNavigation: false
            allowedOrientations: Orientation.Landscape | Orientation.LandscapeInverted
        }
    }
}