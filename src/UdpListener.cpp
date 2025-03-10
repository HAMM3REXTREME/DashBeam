#include "UdpListener.h"

#include <QByteArray>
#include <QDebug>
#include <QHash>
#include <QHostAddress>
#include <cstring>

// Temporary structure to represent the OutGauge Packet
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

outGaugeListener::outGaugeListener(quint16 port, const QHash<int, QString>& ogFlags, const QHash<int, QString>& dlFlags, QObject* parent) : QObject(parent), m_socket(new QUdpSocket(this)), m_port(port), m_ogFlags(ogFlags), m_dlFlags(dlFlags) {
    // Connect the socket to the readyRead signal to process datagrams
    connect(m_socket, &QUdpSocket::readyRead, this, &outGaugeListener::processDatagrams);
}

void outGaugeListener::start() {
    // Bind the socket to the provided port
    if (!m_socket->bind(QHostAddress::Any, m_port)) {
        qWarning() << "start(): Failed to bind UDP socket on port" << m_port;
    } else {
        qDebug() << "start(): UDP listener started on port" << m_port;
    }
}

void outGaugeListener::setPort(quint16 newPort) {
    if (m_socket->state() == QAbstractSocket::BoundState) {
        // If already listening on a port, stop first
        m_socket->close();
    }

    m_port = newPort;
    qDebug() << "setPort(): The port is now" << m_port << "- please call start()";
}

void outGaugeListener::stop() {
    if (m_socket->state() == QAbstractSocket::BoundState) {
        // Close the socket if it is currently bound
        m_socket->close();
        qDebug() << "UDP listener stopped on port" << m_port;
    } else {
        qWarning() << "UDP socket is not currently bound. Nothing to stop.";
    }
}

void outGaugeListener::processDatagrams() {
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
            m_flags = readFlags(packet.flags, m_ogFlags);
            m_gear = packet.gear; // Reverse:0, Neutral:1, First:2...
            m_speed = packet.speed; // M/S
            m_rpm = packet.rpm;
            m_turbo = packet.turbo; // BAR
            m_engTemp = packet.engTemp;
            m_fuel = packet.fuel;
            m_oilTemp = packet.oilTemp;
            m_dashLights = readFlags(packet.dashLights, m_dlFlags); // ALL dash lights
            m_showLights = readFlags(packet.showLights, m_dlFlags); // SHOWN dash lights
            m_throttle = packet.throttle;
            m_brake = packet.brake;
            m_clutch = packet.clutch;
            m_id = packet.id;

            emit outGaugeUpdated();
        } else {
            qWarning() << "Received datagram of unexpected size:" << datagram.size();
        }
    }
}
