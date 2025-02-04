#include "NetInfo.h"

NetworkInfo::NetworkInfo(QObject* parent) : QObject(parent) {
    // Collect the IP addresses
    QStringList ipList;
    QList<QHostAddress> list = QNetworkInterface::allAddresses();
    for (int nIter = 0; nIter < list.count(); nIter++) {
        if (!list[nIter].isLoopback() && list[nIter].protocol() == QAbstractSocket::IPv4Protocol) {
            if (list[nIter].toString() != "0.0.0.0") {
                ipList.append(list[nIter].toString());
            }
        }
    }

    // Join the IP addresses into a single string
    m_ipAddresses = ipList.join("\n");
}

QString NetworkInfo::ipAddresses() const { return m_ipAddresses; }
