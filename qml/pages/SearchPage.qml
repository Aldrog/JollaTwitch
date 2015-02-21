/*
 * Copyright © 2015 Andrew Penkrat
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0
import "elements"
import "scripts/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	property int row: isPortrait ? 2 : 3
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3)*2
	property int offset: 0
	property int totalCount: 0

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "medium"
	}

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	function loadChannels(querry) {
		var url = "https://api.twitch.tv/kraken/search/streams?q=" + querry + "&limit=" + countOnPage + "&offset=" + offset
		console.log(url)
		HTTP.getRequest(url,function(data) {
			if (data) {
				offset += countOnPage
				var result = JSON.parse(data)
				totalCount = result._total
				for (var i in result.streams)
					resultList.append(result.streams[i])
			}
		})
	}

	SilicaGridView {
		id: gridResults
		anchors.fill: parent

		Categories {
			search: false
			following: authToken.value
		}

		PushUpMenu {
			visible: offset < totalCount

			MenuItem {
				text: qsTr("Load more")
				onClicked: {
					loadChannels(gridResults.headerItem.text)
				}
			}
		}

		header: SearchField {
			id: searchQuerry
			width: parent.width
			placeholderText: qsTr("Search channels")
			onTextChanged: {
				resultList.clear()
				offset = 0
				loadChannels(text)
			}
		}

		//This prevents search field from loosing focus when grid changes
		currentIndex: -1

		model: ListModel { id: resultList }
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		delegate: BackgroundItem {
			id: delegate
			width: gridResults.cellWidth
			height: gridResults.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: channel.name })

			Image {
				id: previewImage
				source: preview[previewSize.value]
				anchors.fill: parent
				anchors.margins: Theme.paddingSmall
			}

			OpacityRampEffect {
				sourceItem: previewImage
				direction: OpacityRamp.BottomToTop
				offset: 0.75
				slope: 4.0
			}

			Label {
				id: name
				anchors {
					left: parent.left; leftMargin: Theme.paddingLarge
					right: parent.right; rightMargin: Theme.paddingLarge
					topMargin: Theme.paddingMedium
				}
				text: channel.display_name
				truncationMode: TruncationMode.Fade
				color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
				font.pixelSize: Theme.fontSizeSmall
			}
		}

		VerticalScrollDecorator { flickable: gridResults }
	}
}
