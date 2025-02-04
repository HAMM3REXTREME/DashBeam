#ifndef NETWORKINFO_H
#define NETWORKINFO_H

#include <QHostAddress>
#include <QNetworkInterface>
#include <QObject>
#include <QStringList>

class NetworkInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString ipAddresses READ ipAddresses NOTIFY ipAddressesChanged)

   public:
    explicit NetworkInfo(QObject* parent = nullptr);
    QString ipAddresses() const;

   signals:
    void ipAddressesChanged();

   private:
    QString m_ipAddresses;
};

#endif  // NETWORKINFO_H
