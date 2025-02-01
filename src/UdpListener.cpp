#include "UdpListener.h"
#include <QDebug>
#include <QHostAddress>
#include <QByteArray>
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

UdpListener::UdpListener(quint16 port, QObject *parent)
    : QObject(parent), m_socket(new QUdpSocket(this)), m_port(port)
{
    // Connect the socket to the readyRead signal to process datagrams
    connect(m_socket, &QUdpSocket::readyRead, this, &UdpListener::processDatagrams);
}

void UdpListener::start()
{
    // Bind the socket to the provided port
    if (!m_socket->bind(QHostAddress::Any, m_port)) {
        qWarning() << "Failed to bind UDP socket on port" << m_port;
    } else {
        qDebug() << "UDP listener started on port" << m_port;
    }
}

void UdpListener::processDatagrams()
{
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

            // Emit the signal with the QVariantMap containing the data
            emit outGaugeUpdated(data);
        } else {
            qWarning() << "Received datagram of unexpected size:" << datagram.size();
        }
    }
}
