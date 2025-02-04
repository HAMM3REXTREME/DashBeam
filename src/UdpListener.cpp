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
        qWarning() << "Failed to bind UDP socket on port" << m_port;
    } else {
        qDebug() << "UDP listener started on port" << m_port;
    }
}

void UdpListener::setPort(quint16 newPort) {
    qDebug() << "Changing ports...";
    if (m_socket->state() == QAbstractSocket::BoundState) {
        // If already listening on a port, stop first
        m_socket->close();
    }

    m_port = newPort;
    start();  // Restart with the new port
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
            data["rpm"] = packet.rpm;
            data["speed"] = packet.speed;
            data["throttle"] = packet.throttle;
            data["turbo"] = packet.turbo;
            data["gear"] = packet.gear;
            data["fuel"] = packet.fuel;
            // Read the OG_flags from the packet and check active ones using QHash
            QStringList active_ogFlags = readFlags(packet.flags, m_ogFlags);
            data["flags"] = active_ogFlags;
            // ALL dash lights
            data["dashLights"] = readFlags(packet.dashLights, m_dlFlags);
            // SHOWN dash lights
            data["showLights"] = readFlags(packet.showLights, m_dlFlags);

            // Emit the signal with the QVariantMap containing the data
            emit outGaugeUpdated(data);
        } else {
            qWarning() << "Received datagram of unexpected size:" << datagram.size();
        }
    }
}
