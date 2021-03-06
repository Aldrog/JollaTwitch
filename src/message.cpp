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

#include "message.h"

Message::Message()
{
}

Message::Message(QStringList specs, QColor uColor, QString d_name, QString uname, QString text, QString RTMessage) {
    userSpecificators = specs;
    userColor = uColor;
    displayName = d_name;
    username = uname;
    messageText = text;
    notice = false;
    richTextMessage = RTMessage;
}

Message::Message(QString RTNotice, QString text) {
    userSpecificators = QStringList();
    userColor = QColor();
    displayName = "";
    username = "";
    messageText = text;
    richTextMessage = RTNotice;
    notice = true;
}
