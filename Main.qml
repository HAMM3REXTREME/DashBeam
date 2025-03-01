import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Controls.Material

ApplicationWindow {
    id: root
    visible: true
    width: 1280
    height: 720
    title: "DashBeam"
    Material.theme: Material.Dark

    Component.onCompleted: {
        console.log("Main Window: Starting carListener...")
        carListener.setPort(AppSettings.listenPort)
        carListener.start()
    }
    onClosing: close => {
                   carListener.stop()
                   console.log("Main Window: Stopped carListener. Bye...")
               }

    Settings {
        category: "MainWindow"
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
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
        id: backRect
        width: parent.width
        height: parent.height
        color: "#151515"
        anchors.centerIn: parent

        Rectangle {
            id: centerBox
            width: parent.width * 0.3
            height: parent.height * 0.4
            color: "#060607"
            radius: 4
            anchors.centerIn: parent
            border.color: "#292929"
            border.width: 1
            clip: true
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 64
                blur: 0.05
            }
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
                    saturation: carListener.vehicleThrottle === 1 ? 1.0 : -1.0
                    opacity: carListener.vehicleThrottle === 1 ? 0.75 : 0.25
                }
            }
            Text {
                id: gearText
                anchors.centerIn: parent
                text: (carListener.vehicleGear - 1).toString()
                color: "white"
                font.pixelSize: parent.height / 2
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                id: fuelText
                anchors.left: parent.left
                anchors.bottom: fuelBar.top
                text: "Fuel: " + (carListener.vehicleFuel * 100).toFixed() + "%"
                anchors.leftMargin: 10
                color: "white"
                font.pixelSize: parent.height / 18
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            ColorBar {
                id: fuelBar
                horizontal: true
                width: parent.width * 0.95
                radius: 5
                height: parent.height * 0.02
                anchors.bottom: coolantText.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 5
                value: carListener.vehicleFuel
                fillColor: "#32389f"
            }
            Text {
                id: coolantText
                anchors.left: parent.left
                anchors.bottom: coolantBar.top
                text: "Coolant Temp: " + carListener.vehicleEngTemp.toFixed() + "°C"
                anchors.leftMargin: 10
                color: "white"
                font.pixelSize: parent.height / 18
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            ColorBar {
                id: coolantBar
                horizontal: true
                width: parent.width * 0.95
                radius: 5
                height: parent.height * 0.02
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 5
                value: carListener.vehicleEngTemp / 180
                fillColor: "#9f3244"
            }
        }

        // RPM Gauge
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
            needleValue: carListener.vehicleRpm / 1000
            labelFontSize: radius / 10
            tickFontName: uiFont.name
            backgroundColorOuter: carListener.vehicleShowLights.includes("DL_SHIFT") ? "#492929" : "#292929"
            redline: AppSettings.vRedline > 0 ? AppSettings.vRedline / 1000 : 99999.9
            middleText: "<h1><b>" + carListener.vehicleRpm.toFixed() + "</b></h1>RPM"
            middleFontSize: radius / 8
            middleFontName: circleFont.name
        }

        // Speed Gauge
        CircleMeter {
            id: speedo
            radius: Math.min(parent.width / 6, parent.height / 2) - 10
            width: parent.width / 3
            height: parent.height
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            needleValue: carListener.vehicleSpeed * 3.6 // m/s --> km/h
            tickStep: 2
            tickCount: 151 // 75% + 1 for 3/4 quarters
            tickDivide: 200
            startAngle: 270
            labelSkipEvery: 10
            longTickEvery: 5
            tickFontName: uiFont.name
            redline: 280
            middleText: "<h1><b>" + (carListener.vehicleSpeed * 3.6).toFixed() + "</b></h1>km/h"
            middleFontSize: radius / 8
            middleFontName: circleFont.name
        }
        // Turbo
        CircleMeter {
            id: boostGauge
            visible: carListener.vehicleFlags.includes("OG_TURBO")
            tickStart: -1.5
            radius: Math.min(parent.width / 8, parent.height / 8) - 10
            width: parent.width / 4
            height: parent.height / 4
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.01
            needleValue: carListener.vehicleTurbo
            tickStep: 0.1
            tickCount: 41
            tickDivide: 50
            startAngle: 270
            longTickLength: radius / 8
            shortTickLength: radius / 12
            labelSkipEvery: 5
            longTickEvery: 5
            tickFontName: uiFont.name
            needleWidth: radius / 20
            labelFontSize: radius / 8
            middleText: "<h1><b>" + carListener.vehicleTurbo.toFixed(2) + "</b></h1>bar"
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
                id: turnSignalLeft
                source: "assets/signal_l.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: carListener.vehicleShowLights.includes("DL_SIGNAL_L") ? 1.0 : -1.0
                    opacity: carListener.vehicleShowLights.includes("DL_SIGNAL_L") ? 1.0 : 0.5
                }
            }
            Image {
                id: highbeamOn
                source: "assets/highbeam.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.left: turnSignalLeft.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                // TODO: All the icons should be the same shade of grey when off.
                layer.effect: MultiEffect {
                    saturation: carListener.vehicleShowLights.includes("DL_FULLBEAM") ? 1.0 : -1.0
                    opacity: carListener.vehicleShowLights.includes("DL_FULLBEAM") ? 1.0 : 0.5
                }
            }
            Image {
                id: handbrakeWarn
                source: "assets/handbrake.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.right: turnSignalRight.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: carListener.vehicleShowLights.includes("DL_HANDBRAKE") ? 1.0 : -1.0
                    opacity: carListener.vehicleShowLights.includes("DL_HANDBRAKE") ? 1.0 : 0.5
                }
            }
            Image {
                id: turnSignalRight
                source: "assets/signal_r.svg"
                layer.enabled: true
                width: parent.height - 15
                height: parent.height - 15
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10
                layer.effect: MultiEffect {
                    saturation: carListener.vehicleShowLights.includes("DL_SIGNAL_R") ? 1.0 : -1.0
                    opacity: carListener.vehicleShowLights.includes("DL_SIGNAL_R") ? 1.0 : 0.5
                }
            }
        }
        ShiftLights {
            id: shiftLights
            height: 0.05 * parent.height
            width: 0.025 * numLeds * parent.width * lightAspect
            lightAspect: AppSettings.shiftLightAspect
            visible: AppSettings.enableClientLights ? (AppSettings.vRedline > 0) : carListener.vehicleDashLights.includes("DL_SHIFT")
            maxShiftPoint: AppSettings.vRedline
            vehicleRpm: carListener.vehicleRpm
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.margins: parent.height * 0.025
            shiftSingleOn: !AppSettings.enableClientLights
            numLeds: AppSettings.shiftLightCount
            shiftSingleNow: carListener.vehicleShowLights.includes("DL_SHIFT")
            shadeAll: AppSettings.shiftLightColorAll
        }
        SmoothRpmDisplay {
            id: testDisp
            opacity: 90
            width: parent.width * 0.1
            height: parent.height * 0.85
            tickFontName: uiFont.name
            //anchors.horizontalCenter: parent.horizontalCenter
            //anchors.top: parent.top
            anchors.centerIn: parent
            horizontal: false
            value: carListener.vehicleRpm / 1000
            redlineValue: AppSettings.vRedline / 1000
        }
        RoundButton {
            text: "vert test"
            width: 50
            height: 40
            radius: 5
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 100
            onClicked: testDisp.topLabels = !testDisp.topLabels
        }
        Rectangle {
            id: pedalDisplay
            color: "#1F1F1F"
            width: Math.min(0.075 * parent.width, 0.15 * parent.height)
            height: Math.min(0.075 * parent.width, 0.15 * parent.height)
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
                value: carListener.vehicleClutch
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
                value: carListener.vehicleBrake
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
                value: carListener.vehicleThrottle
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
}
