/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "applicationui.hpp"

#include <bb/cascades/Application>

#include <QLocale>
#include <QTranslator>

#include <Qt/qdeclarativedebug.h>
#include "vendor/Console.hpp"
#include "models/User.hpp"
#include "controllers/loaders/FileDownloader.hpp"
#include "controllers/loaders/PreviewLoader.hpp"


using namespace bb::cascades;

void myMessageOutput(QtMsgType type, const char* msg) {  // <-- ADD THIS
    Q_UNUSED(type);
    fprintf(stdout, "%s\n", msg);
    fflush(stdout);

    QSettings settings;
    if (settings.value("sendToConsoleDebug", true).toBool()) {
        Console* console = new Console();
        console->sendMessage("ConsoleThis$$" + QString(msg));
        console->deleteLater();
    }
}

Q_DECL_EXPORT int main(int argc, char **argv) {
    Application app(argc, argv);

    QTextCodec *codec1 = QTextCodec::codecForName("UTF-8");
    QTextCodec::setCodecForLocale(codec1);
    QTextCodec::setCodecForTr(codec1);
    QTextCodec::setCodecForCStrings(codec1);
    qRegisterMetaType<User*>("User*");
    qRegisterMetaType<FileDownloader*>("FileDownloader*");
    qRegisterMetaType<PreviewLoader*>("PreviewLoader*");
    qmlRegisterUncreatableType<FileDownloader>("chachkouski.type", 1, 0, "downloader", "test");
    qmlRegisterUncreatableType<PreviewLoader>("chachkouski.type", 1, 0, "previewLoader", "test");
    qmlRegisterType<QTimer>("basket.helpers", 1, 0, "Timer");

    // Create the Application UI object, this is where the main.qml file
    // is loaded and the application scene is set.
    ApplicationUI appui;

    qInstallMsgHandler(myMessageOutput);

    // Enter the application main event loop.
    return Application::exec();
}
