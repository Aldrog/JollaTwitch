TARGET = harbour-twitchtube

CONFIG += sailfishapp c++11

SOURCES += \
    main.cpp \
    ircchat.cpp \
    qmlsettings.cpp \
    message.cpp \
    messagelistmodel.cpp \
    iconprovider.cpp

HEADERS += \
    ircchat.h \
    qmlsettings.h \
    message.h \
    messagelistmodel.h \
    iconprovider.h

DISTFILES += qml/harbour-twitchtube.qml \
             qml/CategorySwitcher.qml \
             qml/PersistentPanel.qml \
             qml/SimpleGrid.qml \
             qml/InterfaceConfiguration.qml \
             qml/CategoryButton.qml \
             qml/icons/streams.png \
             qml/icons/games.png \
             harbour-twitchtube.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

LIBS += -L$$OUT_PWD/../backports/ -lBackports
LIBS += -L$$OUT_PWD/../QTwitch/Api/ -lQTwitchApi
LIBS += -L$$OUT_PWD/../QTwitch/Models/ -lQTwitchModels

INCLUDEPATH += $$PWD/../QTwitch
DEPENDPATH += $$PWD/../QTwitch
INCLUDEPATH += $$PWD/../backports
DEPENDPATH += $$PWD/../backports