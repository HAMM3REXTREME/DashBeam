pragma Singleton

import QtCore
import QtQuick

Settings {
    // The properties here are given default values to account for the first run of the application.
    // After the application has run once, future values will come from the stored settings.
    property real vRedline: 5000
    property int shiftLightCount: 9
    property int listenPort: 4444
    property bool enableClientLights: true
    property color shiftLightColorAll: "#E807BB"
    property real shiftLightAspect: 3
}
