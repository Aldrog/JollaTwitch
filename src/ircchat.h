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

#ifndef IRCCHAT_H
#define IRCCHAT_H

#include <QObject>
#include <QTcpSocket>

const qint16 PORT = 6667;
const QString HOST = "irc.twitch.tv";

// Backend for chat
class IrcChat : public QObject
{
	Q_OBJECT
public:
	QString nick, ircpass;
	Q_PROPERTY(QString name MEMBER nick)
	Q_PROPERTY(QString pass MEMBER ircpass)

	IrcChat();
	~IrcChat();

	Q_INVOKABLE void join(const QString channel);
signals:
	void messageReceived(QString sndnick, QString msg);
	void colorReceived(QString nick, QString color);
	void specReceived(QString nick, QString type);
	void specRemoved(QString nick, QString type);
	void errorOccured(QString errorDescription);
public slots:
	void sendMessage(const QString &msg);
private slots:
	void receive();
	void processError(QAbstractSocket::SocketError socketError);
private:
	QTcpSocket *sock;
	QString room;
	void parseCommand(QString cmd);
};

#endif // IRCCHAT_H
