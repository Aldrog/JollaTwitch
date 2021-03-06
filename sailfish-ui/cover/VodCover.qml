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
import "../js/httphelper.js" as HTTP

// The most of this code was taken from Sailfish Silica components

CoverBackground {
    id: root

    property int vodId: mainWindow.currentVodId

    onVodIdChanged: {
        console.log("https://api.twitch.tv/kraken/videos/v" + vodId)
        HTTP.getRequest("https://api.twitch.tv/kraken/videos/v" + vodId, function(data) {
            if(data) {
                var vod = JSON.parse(data)

                // Twitch API doesn't tell anything about preview resolution
                // but atm it gives a url ending with 320x240.jpg and it can be changed to get image with any possible resolution
                // we will rely on this behavior and hope it doesn't change :)

                vodPreview.source = vod.preview.replace("320x240", ~~(root.height * 16/9) + "x" + root.height)
                statusContainer.text = vod.title
            }
        })
    }

    Item {
        id: glassTextureItem
        visible: false
        width: glassTextureImage.width
        height: glassTextureImage.height
        Image {
            id: glassTextureImage
            opacity: 0.1
            scale: Theme.pixelRatio
            source: "image://theme/graphic-shader-texture"
            Behavior on opacity { FadeAnimation { duration: 200 } }
        }
    }

    Image {
        id: vodPreview
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectCrop

        onSourceChanged: {
            // Workaround -- seems to be necessary for the ShaderEffect to update the texture
            wallpaperEffect.wallpaperTexture = null
            wallpaperEffect.wallpaperTexture = vodPreview
        }
    }

    ShaderEffect {
        id: wallpaperEffect
        anchors.fill: parent

        property real horizontalOffset: -(root.height*16/9) / 2 + root.width / 2
        property real verticalOffset: 0

        visible: vodPreview.source != ""

        // offset normalized to effect size
        property size offset: Qt.size(horizontalOffset / width, verticalOffset / height)

        // ratio of effect size vs home wallpaper size
        property real ratio: 1
        property size sizeRatio: Qt.size((9/16)*width/height, 1)

        // glass texture size
        property size glassTextureSizeInv: Qt.size(1.0/glassTextureImage.sourceSize.width, -1.0/glassTextureImage.sourceSize.height)

        property Image wallpaperTexture: vodPreview
        property variant glassTexture: ShaderEffectSource {
            hideSource: true
            sourceItem: glassTextureItem
            wrapMode: ShaderEffectSource.Repeat
        }

        opacity: 0.8

        // Enable blending in compositor (for events view etc..)
        blending: true

        vertexShader: "
            uniform highp mat4 qt_Matrix;
            uniform highp vec2 offset;
            uniform highp vec2 sizeRatio;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying highp vec2 qt_TexCoord0;
            void main() {
               qt_TexCoord0 = (qt_MultiTexCoord0 - offset) * sizeRatio;
               gl_Position = qt_Matrix * qt_Vertex;
            }
        "

        fragmentShader: "
            uniform sampler2D wallpaperTexture;
            uniform sampler2D glassTexture;
            uniform highp vec2 glassTextureSizeInv;
            uniform lowp float qt_Opacity;
            varying highp vec2 qt_TexCoord0;
            void main() {
                lowp vec4 wp = texture2D(wallpaperTexture, qt_TexCoord0);
                lowp vec4 tx = texture2D(glassTexture, gl_FragCoord.xy * glassTextureSizeInv);
                gl_FragColor = vec4(0.8*wp.rgb + tx.rgb, 1.0)" + (blending ? "*qt_Opacity" : "") + ";
            }
        "
    }

    CoverPlaceholder {
        id: statusContainer
        icon.source: "../images/icon.png"
    }
}
