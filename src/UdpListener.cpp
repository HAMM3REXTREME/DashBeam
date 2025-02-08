#include "UdpListener.h"

#include <QByteArray>
#include <QDebug>
#include <QHash>
#include <QHostAddress>
#include <cstring>

// Temporary structure to represent the OutGaugePacket
struct OutGaugePacket {
    uint32_t time;
    char name[4];
    uint16_t flags;
    char gear;
    char plid;
    float speed;
    float rpm;
    float turbo;
    float engTemp;
    float fuel;
    float oilPressure;
    float oilTemp;
    uint32_t dashLights;
    uint32_t showLights;
    float throttle;
    float brake;
    float clutch;
    char display1[16];
    char display2[16];
    int id;
};

// Function to check which flags are active using QHash
QStringList readFlags(int value, const QHash<int, QString>& flags) {
    QStringList active_flags;

    // Iterate through the hash and check which flags are set
    for (auto it = flags.constBegin(); it != flags.constEnd(); ++it) {
        if (value & it.key()) {
            active_flags.append(it.value());
        }
    }

    return active_flags;
}

UdpListener::UdpListener(quint16 port, const QHash<int, QString>& ogFlags, const QHash<int, QString>& dlFlags, QObject* parent) : QObject(parent), m_socket(new QUdpSocket(this)), m_port(port), m_ogFlags(ogFlags), m_dlFlags(dlFlags) {
    // Connect the socket to the readyRead signal to process datagrams
    connect(m_socket, &QUdpSocket::readyRead, this, &UdpListener::processDatagrams);
}

void UdpListener::start() {
    // Bind the socket to the provided port
    if (!m_socket->bind(QHostAddress::Any, m_port)) {
        qWarning() << "start(): Failed to bind UDP socket on port" << m_port;
    } else {
        qDebug() << "start(): UDP listener started on port" << m_port;
    }
}

void UdpListener::setPort(quint16 newPort) {
    if (m_socket->state() == QAbstractSocket::BoundState) {
        // If already listening on a port, stop first
        m_socket->close();
    }

    m_port = newPort;
    qDebug() << "setPort(): The port is now" << m_port << "- please call start()";
}

void UdpListener::stop() {
    if (m_socket->state() == QAbstractSocket::BoundState) {
        // Close the socket if it is currently bound
        m_socket->close();
        qDebug() << "UDP listener stopped on port" << m_port;
    } else {
        qWarning() << "UDP socket is not currently bound. Nothing to stop.";
    }
}

void UdpListener::processDatagrams() {
    while (m_socket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(int(m_socket->pendingDatagramSize()));

        QHostAddress sender;
        quint16 senderPort;

        // Read the datagram
        m_socket->readDatagram(datagram.data(), datagram.size(), &sender, &senderPort);

        // Ensure we received the expected number of bytes (matching OutGaugePacket)
        if (datagram.size() == sizeof(OutGaugePacket)) {
            OutGaugePacket packet;
            // Copy the received datagram into the OutGaugePacket struct
            std::memcpy(&packet, datagram.data(), sizeof(OutGaugePacket));
            // Create a QVariantMap to hold the parsed data so we can access it via QML
            QVariantMap data;
            data["flags"] = readFlags(packet.flags, m_ogFlags);
            data["gear"] = packet.gear; // Reverse:0, Neutral:1, First:2...
            data["speed"] = packet.speed; // M/S
            data["rpm"] = packet.rpm;
            data["turbo"] = packet.turbo; // BAR
            data["engTemp"] = packet.engTemp;
            data["fuel"] = packet.fuel;
            data["oilTemp"] = packet.oilTemp;
            data["dashLights"] = readFlags(packet.dashLights, m_dlFlags); // ALL dash lights
            data["showLights"] = readFlags(packet.showLights, m_dlFlags); // SHOWN dash lights
            data["throttle"] = packet.throttle;
            data["brake"] = packet.brake;
            data["clutch"] = packet.clutch;
            data["id"] = packet.id;


            // Emit the signal with the QVariantMap containing the data
            emit outGaugeUpdated(data);
        } else {
            qWarning() << "Received datagram of unexpected size:" << datagram.size();
        }
    }
}
