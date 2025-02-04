#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "UdpListener.h"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // Define the OutGauge (OG) flags
    QHash<int, QString> og_flags;
    og_flags[1] = "OG_SHIFT";        // key // N/A
    og_flags[2] = "OG_CTRL";         // key // N/A
    og_flags[8192] = "OG_TURBO";     // show turbo gauge
    og_flags[16384] = "OG_KM";       // user prefers MILES if not set
    og_flags[32768] = "OG_BAR";      // user prefers PSI if not set

    // Define the DashLight (DL) flags
    QHash<int, QString> dl_flags;
    dl_flags[1] = "DL_SHIFT";        // shift light
    dl_flags[2] = "DL_FULLBEAM";     // full beam
    dl_flags[4] = "DL_HANDBRAKE";    // handbrake
    dl_flags[8] = "DL_PITSPEED";     // pit speed limiter // N/A
    dl_flags[16] = "DL_TC";          // tc active or switched off
    dl_flags[32] = "DL_SIGNAL_L";    // left turn signal
    dl_flags[64] = "DL_SIGNAL_R";    // right turn signal
    dl_flags[128] = "DL_SIGNAL_ANY"; // shared turn signal // N/A
    dl_flags[256] = "DL_OILWARN";    // oil pressure warning
    dl_flags[512] = "DL_BATTERY";    // battery warning
    dl_flags[1024] = "DL_ABS";       // abs active or switched off
    dl_flags[2048] = "DL_SPARE";     // N/A

    // Create the UdpListener and start listening on port 4444
    UdpListener udpListener(4444, og_flags, dl_flags); // Change to your UDP port
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
