#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "UdpListener.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Create the UdpListener and start listening on port 4444
    UdpListener udpListener(4444); // Change to your UDP port
    udpListener.start();

    // Expose the UdpListener to QML so that we can access it in the QML UI
    engine.rootContext()->setContextProperty("udpListener", &udpListener);

    // Load the QML file into the engine
    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/Main/main.qml")));

    // Check if the QML file is loaded successfully
    if (engine.rootObjects().isEmpty()) {
        return -1; // Exit if QML doesn't load properly
    }

    return app.exec(); // Start the Qt application event loop
}
