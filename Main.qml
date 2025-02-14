import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Controls.Material

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "DashBeam"

    Material.theme: Material.Dark
    Component.onCompleted: {
        console.log("Main Window: Starting udpListener...")
        udpListener.setPort(ogPort)
        udpListener.start()
    }
    onClosing: close => {
                   udpListener.stop()
                   console.log("Main Window: Stopped udpListener. Bye...")
               }
    FontLoader {
        id: uiFont
        source: "assets/Aldrich-Regular.ttf"
    }
    FontLoader {
        id: circleFont
        source: "assets/JetBrainsMono-Bold.ttf"
    }
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#151515"
        anchors.centerIn: parent

        // Central display
        Rectangle {
            id: centerBox
            width: parent.width * 0.3
            height: parent.height * 0.3
            color: "#060607"
            radius: 4
            anchors.centerIn: parent
            border.color: "#292929"
            border.width: 1
            clip: true
            Image {
                id: brandingIcon
                source: "assets/screen_topleft.svg"
                layer.enabled: true
                width: parent.height
                height: parent.height
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 5
                layer.effect: MultiEffect {
                    saturation: vThrottle == 1 ? 1.0 : -1.0
                    opacity: vThrottle == 1 ? 1.0 : 0.5
                }
            }
            Text {
                anchors.centerIn: parent
                text: (vGear - 1).toString()
                color: "white"
                font.pixelSize: parent.height / 2
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            ColorBar {
                id: fuelBar
                horizontal: true
                width: parent.width * 0.95
                radius: 5
                height: parent.height * 0.1
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 5
                value: vFuel
                fillColor: "#32389f"
            }
        }

        // RPM Gauge (Left)
        CircleMeter {
            id: tacho
            radius: Math.min(parent.width / 6, parent.height / 2) - 10
            width: parent.width / 3
            height: parent.height
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            tickStep: 0.5 / 5
            tickCount: 91
            tickDivide: 120
            longTickEvery: 5
            labelSkipEvery: 10
            needleValue: vRpm / 1000
            labelFontSize: radius / 10
            tickFontName: uiFont.name
            tickColor: "#FE8000"
            strokeColor: "#FE8000"
            labelFontColor: "#FE8000"
            backgroundColorInner: vShowLights.includes(
                                      "DL_SHIFT") ? "#392424" : "#242424"
            redline: clShiftPoint > 0 ? clShiftPoint / 1000 : 99999.9
            middleText: "<h1><b>" + vRpm.toFixed() + "</b></h1>RPM"
            middleFontSize: radius / 8
            middleFontName: circleFont.name
        }

        // Speed Gauge (Right)
        CircleMeter {
            id: speedo
            radius: Math.min(parent.width / 6, parent.height / 2) - 10
            width: parent.width / 3
            height: parent.height
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            needleValue: vSpeed
            tickStep: 2
            tickCount: 151 // 75% + 1 for 3/4 quarters
            tickDivide: 200
            startAngle: 270
            tickColor: "#FE8000"
            strokeColor: "#FE8000"
            labelFontColor: "#FE8000"
            labelSkipEvery: 10
            longTickEvery: 5
            tickFontName: uiFont.name
            redline: 280
            middleText: "<h1><b>" + vSpeed.toFixed() + "</b></h1>km/h"
            middleFontSize: radius / 8
            middleFontName: circleFont.name
        }
        // Turbo
        CircleMeter {
            id: boostGauge
            visible: vFlags.includes("OG_TURBO")
            tickStart: -1.5
            radius: Math.min(parent.width / 8, parent.height / 8) - 10
            width: parent.width / 4
            height: parent.height / 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.01
            needleValue: vTurbo
            tickStep: 0.1
            tickCount: 41
            tickDivide: 50
            startAngle: 270
            tickColor: "#FE8000"
            strokeColor: "#FE8000"
            labelFontColor: "#FE8000"
            longTickLength: radius / 8
            shortTickLength: radius / 12
            labelSkipEvery: 5
            longTickEvery: 5
            tickFontName: uiFont.name
            needleWidth: radius / 20
            labelFontSize: radius / 8
            middleText: "<h1><b>" + vTurbo.toFixed(2) + "</b></h1>bar"
            middleFontSize: radius / 8
            middleFontName: circleFont.name
        }

        Rectangle {
            id: indicators
            width: 0.4 * parent.width
            height: 0.08 * parent.height
            color: "#1F1F1F"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.margins: parent.height * 0.1
            radius: height / 5
            border.color: "#292929"
            border.width: 1
            Image {
                id: sourceItemL
                source: "assets/signal_l.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: vShowLights.includes("DL_SIGNAL_L") ? 1.0 : -1.0
                    opacity: vShowLights.includes("DL_SIGNAL_L") ? 1.0 : 0.5
                }
            }
            Image {
                id: highbeamImg
                source: "assets/highbeam.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.left: sourceItemL.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: vShowLights.includes("DL_FULLBEAM") ? 1.0 : -1.0
                    opacity: vShowLights.includes("DL_FULLBEAM") ? 1.0 : 0.5
                }
            }
            Image {
                id: handbrakeWarn
                source: "assets/handbrake.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.right: sourceItemR.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: vShowLights.includes(
                                    "DL_HANDBRAKE") ? 1.0 : -1.0
                    opacity: vShowLights.includes("DL_HANDBRAKE") ? 1.0 : 0.5
                }
            }
            Image {
                id: sourceItemR
                source: "assets/signal_r.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                // For the layered items, you can assign a MultiEffect directly
                // to layer.effect.
                layer.effect: MultiEffect {
                    saturation: vShowLights.includes("DL_SIGNAL_R") ? 1.0 : -1.0
                    opacity: vShowLights.includes("DL_SIGNAL_R") ? 1.0 : 0.5
                }
            }
        }
        ShiftLights {
            id: shiftLights
            visible: showMultiLights ? (clShiftPoint > 0) : vDashLights.includes(
                                           "DL_SHIFT")
            maxShiftPoint: clShiftPoint
            vehicleRpm: vRpm
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.margins: parent.height * 0.025
            shiftSingleOn: !showMultiLights
            numLeds: numShiftLeds
            shiftSingleNow: vShowLights.includes("DL_SHIFT")
        }
        // Pedal inputs
        Rectangle {
            color: "#1F1F1F"
            width: 0.075 * parent.width
            height: 0.15 * parent.height
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            border.color: "#292929"
            border.width: 1
            radius: 5
            anchors.margins: 10
            ColorBar {
                id: clutchBar
                width: parent.width / 4
                radius: 5
                height: parent.height * 0.9
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: 5
                value: vClutch
                fillColor: "#23319f"
            }
            ColorBar {
                id: brakeBar
                width: parent.width / 4
                radius: 5
                height: parent.height * 0.9
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 5
                value: vBrake
                fillColor: "#9f2831"
            }
            ColorBar {
                id: throttleBar
                width: parent.width / 4
                radius: 5
                height: parent.height * 0.9
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.margins: 5
                value: vThrottle
                fillColor: "#239f21"
            }
        }
        RoundButton {
            text: "Settings"
            width: 100
            height: 40
            radius: 5
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 10
            onClicked: settingsLoader.source = "SettingsPage.qml"
        }
    }

    // Settings Page Loader
    Loader {
        id: settingsLoader
        anchors.fill: parent
    }
    property var vFlags: []
    property int vGear: 0
    property real vSpeed: 0.0
    property real vRpm: 0.0
    property real vTurbo: 0.0
    property real vEngTemp: 0.0
    property real vFuel: 0.0
    property real vOilTemp: 0.0
    property var vDashLights: []
    property var vShowLights: []
    property real vThrottle: 0.0
    property real vBrake: 0.0
    property real vClutch: 0.0
    property int vId: 0
    // Client side options
    property real clShiftPoint: settingsManager.loadSetting("shiftPoint", -1.0)
    property int numShiftLeds: settingsManager.loadSetting("numLeds", 9)
    property int ogPort: settingsManager.loadSetting("ogPort", 4444)
    property bool showMultiLights: settingsManager.loadSetting("isShift", false)

    // Connect to C++ signal for a packet
    Connections {
        target: udpListener
        function onOutGaugeUpdated(data) {
            vFlags = data.flags
            vGear = data.gear
            vSpeed = data.speed * 3.6 // Convert speed from m/s to km/h
            vRpm = data.rpm
            vTurbo = data.turbo
            vEngTemp = data.engTemp
            vFuel = data.fuel
            vOilTemp = data.oilTemp
            vDashLights = data.dashLights
            vShowLights = data.showLights
            vThrottle = data.throttle
            vBrake = data.brake
            vClutch = data.clutch
            vId = data.id
        }
    }
    Connections {
        target: settingsManager
        function onSettingChanged(key, value) {
            if (key === "ogPort") {
                ogPort = value
                udpListener.setPort(ogPort)
                udpListener.start()
            } else if (key === "shiftPoint") {
                clShiftPoint = value
            } else if (key === "isShift") {
                showMultiLights = value
            } else if (key === "numLeds") {
                numShiftLeds = value
            }
        }
    }
}
