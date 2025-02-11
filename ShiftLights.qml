import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

Rectangle {
    id: shiftLights
    property bool shiftSingleNow: false // Only works when maxShiftPoint is not a natural number
    property real maxShiftPoint: 9000
    property real vehicleRpm: 0
    height: 0.05 * parent.height
    width: maxShiftPoint > 0 ? numLeds * height : 0.1 * parent.width
    color: "#1F1F1F"
    radius: height / 5
    border.color: "#292929"
    border.width: 1
    // This part: ---______
    property color shadeOnLow: "#5dd317"
    property color shadeOffLow: "#445e31"
    // ___---___
    property color shadeOnMiddle: '#d6b10d'
    property color shadeOffMiddle: '#5b5228'
    // ______---
    property color shadeOnHigh: "#CF0404"
    property color shadeOffHigh: "#1F0505"
    // All parts: ---------
    property color shadeAll: "#e807bb"
    property real lightRpmStep: 100
    // Repeater to create an array of shift lights
    Repeater {
        model: numLeds
        Rectangle {
            id: led
            width: maxShiftPoint > 0 ? parent.height * 0.8 : parent.width * 0.8
            height: parent.height * 0.8
            radius: width / 2
            property bool isOn: false
            color: {
                // Only for client side shift lights
                if (maxShiftPoint > 0) {
                    // Yellows - default shade
                    let shadeOff = shiftLights.shadeOffMiddle
                    let shadeOn = shiftLights.shadeOnMiddle
                    // (numLeds-index) == (left --> 1,2,3,4,5,6,7,8,9 --> right)
                    if ((numLeds - index) > 6) {
                        // Left lights = Green
                        shadeOff = shiftLights.shadeOffLow
                        shadeOn = shiftLights.shadeOnLow
                    }
                    if ((numLeds - index) <= 3) {
                        // Right lights = Red
                        shadeOn = shiftLights.shadeOnHigh
                        shadeOff = shiftLights.shadeOffHigh
                    }
                    if (vehicleRpm >= maxShiftPoint) {
                        shadeOn = shiftLights.shadeAll // SHIFT NOW type color
                    }
                    if (vehicleRpm >= (maxShiftPoint - (numLeds - index) * lightRpmStep)) {
                        isOn = true
                        return shadeOn
                    } else {
                        isOn = false
                        return shadeOff
                    }
                } else {
                    // BeamNG shift lights
                    if (shiftSingleNow) {
                        return "#CF0404" // Red color when the shift light is shown
                    } else {
                        return "#1F0505" // Dark red if the shift light is not shown
                    }
                }
            }
            // Position each circle in a horizontal line
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: (index - (numLeds - 1) / 2) * (width * 1.1)
            anchors.verticalCenter: parent.verticalCenter
            border.color: "#252525"
            border.width: 1
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: isOn
                blurMax: 64
                blur: 0.1
            }
        }
    }
}
