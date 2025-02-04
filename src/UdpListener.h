#ifndef UDP_LISTENER_H
#define UDP_LISTENER_H

#include <QHostAddress>
#include <QObject>
#include <QUdpSocket>
#include <QVariantMap>

class UdpListener : public QObject {
    Q_OBJECT

   public:
    explicit UdpListener(quint16 port, const QHash<int, QString> &ogFlags, const QHash<int, QString> &dlFlags, QObject *parent = nullptr);
    // Start listening for UDP datagrams
    void start();
   public slots:
    void setPort(quint16 newPort);

   signals:
    // Signal to pass the data to QML as QVariantMap
    void outGaugeUpdated(const QVariantMap &data);

   private slots:
    // Slot to process incoming UDP datagrams
    void processDatagrams();

   private:
    QUdpSocket *m_socket;  // Socket for UDP communication
    quint16 m_port;        // Port to listen to
    QHash<int, QString> m_ogFlags;
    QHash<int, QString> m_dlFlags;
};

#endif  // UDP_LISTENER_H
