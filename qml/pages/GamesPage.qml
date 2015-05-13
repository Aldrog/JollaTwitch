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
import "elements"
import "../js/httphelper.js" as HTTP

Page {
	id: page
	allowedOrientations: Orientation.All

	// Status for NavigationCover
	property string navStatus: qsTr("Games")

	GamesGrid {
		id: gridGames

		function loadGames() {
			var url = "https://api.twitch.tv/kraken/games/top?limit=" + countOnPage + "&offset=" + offset
			console.log(url)
			HTTP.getRequest(url,function(data) {
				if (data) {
					offset += countOnPage
					var result = JSON.parse(data)
					totalCount = result._total
					for (var i in result.top)
						model.append(result.top[i].game)
				}
			})
		}

		Categories {
			games: false
		}

		header: PageHeader {
			title: qsTr("Popular Games")
		}
	}
}


