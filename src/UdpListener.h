#ifndef UDP_LISTENER_H
#define UDP_LISTENER_H

#include <QObject>
#include <QUdpSocket>
#include <QVariantMap>
#include <QHostAddress>

class UdpListener : public QObject
{
    Q_OBJECT

public:
    explicit UdpListener(quint16 port, QObject *parent = nullptr);

    // Start listening for UDP datagrams
    void start();

signals:
    // Signal to pass the data to QML as QVariantMap
    void outGaugeUpdated(const QVariantMap &data);

private slots:
    // Slot to process incoming UDP datagrams
    void processDatagrams();

private:
    QUdpSocket *m_socket;  // Socket for UDP communication
    quint16 m_port;        // Port to listen to
};

#endif // UDP_LISTENER_H
