#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>

class SettingsManager : public QObject
{
    Q_OBJECT
   public:
    explicit SettingsManager(QObject *parent = nullptr);

    // Save a setting with a given key and value
    Q_INVOKABLE void saveSetting(const QString &key, const QVariant &value);

    // Load a setting with a given key, returns defaultValue if not found
    Q_INVOKABLE QVariant loadSetting(const QString &key, const QVariant &defaultValue = QVariant());

    signals:
        void settingChanged(const QString &key, const QVariant &value); // Signal for setting changes

   private:
    QSettings *settings;
};

#endif // SETTINGSMANAGER_H
