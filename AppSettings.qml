pragma Singleton

import QtCore
import QtQuick

Settings {
    // The properties here are given default values to account for the first run of the application.
    // After the application has run once, future values will come from the stored settings.
    property real clShiftPoint: 5000
    property int numShiftLeds: 9
    property int ogPort: 4444
    property bool showMultiLights: true
    property color shiftLightAllColor: "#e807bb"
}
