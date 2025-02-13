#include <QDebug>
#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    settings = new QSettings("hamm3r", "DashBeam", this);
}

void SettingsManager::saveSetting(const QString &key, const QVariant &value)
{
    // Save the setting
    qDebug() << "SettingsManager: Saving setting with key:" << key << "and value" << value;
    settings->setValue(key, value);
    emit settingChanged(key, value); // Notify QML about the change
}

// loadSetting("someKey", "false") --> "true"/"false" (QML will consider both of these true!)
// loadSetting("someKey", false) --> true/false
QVariant SettingsManager::loadSetting(const QString &key, const QVariant &defaultValue)
{
    QVariant value = settings->value(key, defaultValue);
    // If the default value is a boolean, the caller expects a boolean back (important since QML will consider "false" as true and "true" as true)
    // ensure booleans are returned correctly (true not "true" and false not "false")
    if (defaultValue.metaType() == QMetaType::fromType<bool>()){
        qDebug() << "Loaded" << key << "as a boolean with value:" << value.toBool();
        return value.toBool();
    }
    qDebug() << "Loaded" << key << "with value:" << value;
    // Not handling the other cases (int, double etc.) since in QML, the QString "1234.5" will be converted properly to 1234.5 etc.
    return value;
}
