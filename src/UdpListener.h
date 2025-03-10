#ifndef UDP_LISTENER_H
#define UDP_LISTENER_H

#include <QHostAddress>
#include <QObject>
#include <QUdpSocket>
#include <QVariantMap>

class outGaugeListener : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList vehicleFlags READ vehicleFlags NOTIFY outGaugeUpdated)
    Q_PROPERTY(char vehicleGear READ vehicleGear NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleSpeed READ vehicleSpeed NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleRpm READ vehicleRpm NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleTurbo READ vehicleTurbo NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleEngTemp READ vehicleEngTemp NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleFuel READ vehicleFuel NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleOilTemp READ vehicleOilTemp NOTIFY outGaugeUpdated)
    Q_PROPERTY(QStringList vehicleDashLights READ vehicleDashLights NOTIFY outGaugeUpdated)
    Q_PROPERTY(QStringList vehicleShowLights READ vehicleShowLights NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleThrottle READ vehicleThrottle NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleBrake READ vehicleBrake NOTIFY outGaugeUpdated)
    Q_PROPERTY(float vehicleClutch READ vehicleClutch NOTIFY outGaugeUpdated)
    Q_PROPERTY(int vehicleId READ vehicleId NOTIFY outGaugeUpdated)

   public:
    explicit outGaugeListener(quint16 port, const QHash<int, QString> &ogFlags, const QHash<int, QString> &dlFlags, QObject *parent = nullptr);
   public slots:
    void start();
    void setPort(quint16 newPort);
    void stop();
    // Getters for vehicle data.
    QStringList vehicleFlags(){return m_flags;}
    char vehicleGear(){return m_gear;}
    float vehicleSpeed(){return m_speed;}
    float vehicleRpm(){return m_rpm;}
    float vehicleTurbo(){return m_turbo;}
    float vehicleEngTemp(){return m_engTemp;}
    float vehicleFuel(){return m_fuel;}
    float vehicleOilTemp(){return m_oilTemp;}
    QStringList vehicleDashLights() {return m_dashLights;}
    QStringList vehicleShowLights() {return m_showLights;}
    float vehicleThrottle(){return m_throttle;}
    float vehicleBrake(){return m_brake;}
    float vehicleClutch(){return m_clutch;}
    int vehicleId(){return m_id;}

   signals:
    // Signal to pass the data to QML as QVariantMap
    void outGaugeUpdated();

   private slots:
    // Slot to process incoming UDP datagrams
    void processDatagrams();

   private:
    QUdpSocket *m_socket;  // Socket for UDP communication
    quint16 m_port;        // Port to listen to
    // Lookup values
    QHash<int, QString> m_ogFlags;
    QHash<int, QString> m_dlFlags;
    // Store live vehicle info
    QStringList m_flags;
    char m_gear = 1;
    float m_speed = 0;
    float m_rpm = 0;
    float m_turbo = 0;
    float m_engTemp = 0;
    float m_fuel = 0;
    float m_oilTemp = 0;
    QStringList m_dashLights;
    QStringList m_showLights;
    float m_throttle = 0;
    float m_brake = 0;
    float m_clutch = 0;
    int m_id = 0;
};

#endif  // UDP_LISTENER_H
