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

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("DashBeam", "Main");

    return app.exec();
}
