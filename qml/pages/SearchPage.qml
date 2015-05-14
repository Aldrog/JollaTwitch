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

import QtQuick 2.2
import Sailfish.Silica 1.0
import "elements"
import "../js/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	// Status for NavigationCover
	property string navStatus: qsTr("Search")

	ChannelsGrid {
		id: gridResults
		autoLoad: false
		property string querry: ""

		function loadChannels() {
			var url = "https://api.twitch.tv/kraken/search/streams?q=" + querry + "&limit=" + countOnPage + "&offset=" + offset
			console.log(url)
			HTTP.getRequest(url,function(data) {
				if (data) {
					offset += countOnPage
					var result = JSON.parse(data)
					totalCount = result._total
					for (var i in result.streams)
						model.append(result.streams[i])
				}
			})
		}

		Categories {
			search: false
		}

		header: SearchField {
			id: searchQuerry
			width: parent.width
			placeholderText: qsTr("Search channels")
			onTextChanged: {
				gridResults.model.clear()
				gridResults.offset = 0
				gridResults.querry = text
				gridResults.loadChannels()
			}
		}

		// This prevents search field from loosing focus when grid changes
		currentIndex: -1
	}
}
