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

	property int row: isPortrait ? 2 : 3
	//in brackets should be row lengths for portrait and landscape orientations
	property int countOnPage: (2*3)*3
	property string nextlink

	ConfigurationValue {
		id: previewSize
		key: "/apps/twitch/settings/previewimgsize"
		defaultValue: "large"
	}

	ConfigurationValue {
		id: authToken
		key: "/apps/twitch/settings/oauthtoken"
		defaultValue: ""
	}

	SilicaGridView {
		id: gridChannels
		anchors.fill: parent

		Categories {
			following: false
		}

		PushUpMenu {
			MenuItem {
				text: qsTr("Load more")
				onClicked: {
					HTTP.getRequest(nextlink,function(data) {
						if (data) {
							var result = JSON.parse(data)
							nextlink = result._links.next
							for (var i in result.streams)
								streamList.append(result.streams[i])
						}
					})
				}
			}
		}

		header: PageHeader {
			title: qsTr("Followed Streams")
		}

		model: ListModel { id: streamList }
		cellWidth: width/row
		cellHeight: cellWidth*5/8

		delegate: BackgroundItem {
			id: delegate
			width: gridChannels.cellWidth
			height: gridChannels.cellHeight
			onClicked: pageStack.push (Qt.resolvedUrl("StreamPage.qml"), { channel: channel.name })

			Image {
				id: previewImage
				source: preview[previewSize.value]
				anchors {
					fill: parent
					leftMargin: Theme.paddingSmall
					rightMargin: Theme.paddingSmall
					topMargin: Theme.paddingSmall
					bottomMargin: Theme.paddingSmall
				}
				visible: false
			}

			ShaderEffect {
				anchors.fill: previewImage
				property variant src: previewImage
				property real h: name.height/height
				vertexShader: "
					uniform highp mat4 qt_Matrix;
					attribute highp vec4 qt_Vertex;
					attribute highp vec2 qt_MultiTexCoord0;
					varying highp vec2 coord;
					void main() {
						coord = qt_MultiTexCoord0;
						gl_Position = qt_Matrix * qt_Vertex;
					}"
				fragmentShader: "
					varying highp vec2 coord;
					uniform sampler2D src;
					uniform lowp float h;
					uniform lowp float qt_Opacity;
					void main() {
						lowp vec4 tex = texture2D(src, coord);
						if(coord.y <= h)
							tex = vec4((tex.rgb)*(coord.y/(h)), coord.y/(h));
						gl_FragColor = tex * qt_Opacity;
					}"
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

		VerticalScrollDecorator { flickable: gridChannels }
	}

	Component.onCompleted: {
		var url = "https://api.twitch.tv/kraken/streams/followed?oauth_token=" + authToken.value + "&limit=" + countOnPage
		console.log(url)
		HTTP.getRequest(url,function(data) {
			if (data) {
				var result = JSON.parse(data)
				nextlink = result._links.next
				for (var i in result.streams)
					streamList.append(result.streams[i])
			}
		})
	}
}