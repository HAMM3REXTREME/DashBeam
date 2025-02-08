#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent) : QObject(parent)
{
    settings = new QSettings("hamm3r", "DashBeam", this);
}

void SettingsManager::saveSetting(const QString &key, const QVariant &value)
{
    // Save the setting
    settings->setValue(key, value);
}

QVariant SettingsManager::loadSetting(const QString &key, const QVariant &defaultValue)
{
    // Load the setting, return defaultValue if the setting does not exist
    return settings->value(key, defaultValue);
}
