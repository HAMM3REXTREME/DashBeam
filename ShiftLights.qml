import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

Rectangle {
    id: shiftLights
    property int numLeds: 9
    property bool shiftSingleNow: false // Only works when shiftSingleOn
    property bool shiftSingleOn: false // Show single light that doesnt depend on rpm, just set by boolean.
    property real maxShiftPoint: 9000
    property real vehicleRpm: 0
    property real lightAspect: 1 // Aspect ratio of lights, <1 looks like "|" and >1 looks like "-"
    property real lightRadiusFactor: 0.5 // Rounding radius factor, 0 = no rounding, 0.5 = pill shape/circle
    property bool forceLightAspect: true // Force light aspect, or simply use parent width and height for the lights
    property bool isVertical: false // Makes lights stack vertically instead
    height: 50
    width: 500
    color: "#1F1F1F"
    radius: (forceLightAspect ? (lightAspect * height) : width * 0.8 / numLeds) * lightRadiusFactor
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
        id: ledRepeater
        model: numLeds
        Rectangle {
            id: led
            width: forceLightAspect ? (lightAspect * height) : parent.width * 0.8 / (isVertical ? 1 : numLeds)
            height: forceLightAspect ? Math.min(parent.width * 0.8 / (numLeds * lightAspect),
                                                (parent.height * 0.8) / (isVertical ? numLeds : 1)) : parent.height * 0.8
            radius: width * lightRadiusFactor
            property bool isOn: false
            color: {
                // Only for client side shift lights
                if (!shiftSingleOn) {
                    // Yellows - default shade
                    let shadeOff = shiftLights.shadeOffMiddle
                    let shadeOn = shiftLights.shadeOnMiddle
                    if (index < shiftLights.numLeds / 3) {
                        // Left lights = Green
                        shadeOff = shiftLights.shadeOffLow
                        shadeOn = shiftLights.shadeOnLow
                    }
                    if (index >= 2 * shiftLights.numLeds / 3 | index + 1 === shiftLights.numLeds) {
                        // Right lights = Red
                        shadeOn = shiftLights.shadeOnHigh
                        shadeOff = shiftLights.shadeOffHigh
                    }
                    if (vehicleRpm >= maxShiftPoint) {
                        shadeOn = shiftLights.shadeAll // SHIFT NOW type color
                    }
                    // (numLeds-index) == (left --> 1,2,3,4,5,6,7,8,9 --> right)
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
                        isOn = true
                        shiftLights.shadeOnHigh // Red color when the shift light is shown
                    } else {
                        isOn = false
                        shiftLights.shadeOffHigh // Dark red if the shift light is not shown
                    }
                }
            }
            states: [
                State {
                    name: "horizontal"
                    when: !isVertical
                    PropertyChanges {
                        target: led
                        anchors.horizontalCenterOffset: (index - (numLeds - 1) / 2) * (width * 1.1)
                        anchors.verticalCenterOffset: 0
                    }
                },
                State {
                    name: "vertical"
                    when: isVertical
                    PropertyChanges {
                        target: led
                        anchors.horizontalCenterOffset: 0
                        anchors.verticalCenterOffset: (((numLeds - 1) / 2) - index) * (height * 1.1)
                    }
                }
            ]
            anchors.horizontalCenter: parent.horizontalCenter
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
