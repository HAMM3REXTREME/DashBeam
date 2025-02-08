import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "DashBeam - BeamNG dashboard"

    //Material.theme: Material.Dark
    Component.onCompleted: {
        console.log("Main Window: Starting udpListener...")
        udpListener.setPort(ogPort)
        udpListener.start()
    }
    onClosing: close => {
                   udpListener.stop()
               }
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#191919"
        anchors.centerIn: parent

        // Central display
        Rectangle {
            id: centerBox
            width: parent.width * 0.3
            height: parent.height * 0.4
            color: "#060607"
            radius: 4
            anchors.centerIn: parent
            border.color: "#292929"
            border.width: 1
            FontLoader {
                id: uiFont
                source: "assets/Aldrich-Regular.ttf"
            }
            Text {
                anchors.centerIn: parent
                text: "DashBeam\nBeamNG Drive Dashboard"
                color: "white"
                font.pixelSize: 16
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                id: throttleBar
                width: 10
                height: vThrottle * 50
                color: "green"
                anchors.bottom: parent.bottom
                anchors.right: parent.right
            }
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
        tickColor: "#FE8000"
        strokeColor: "#FE8000"
        backgroundColorInner: vShowLights.includes(
                                  "DL_SHIFT") ? "#392424" : "#242424"
        redline: clShiftPoint > 0 ? clShiftPoint / 1000 : 99999.9
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
        labelSkipEvery: 10
        longTickEvery: 5
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
            source: "assets/signal_l.png"
            layer.enabled: true
            width: parent.height - 10
            height: parent.height - 10
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10
            // For the layered items, you can assign a MultiEffect directly
            // to layer.effect.
            layer.effect: MultiEffect {
                saturation: vShowLights.includes("DL_SIGNAL_L") ? 1.0 : -1.0
                opacity: vShowLights.includes("DL_SIGNAL_L") ? 1.0 : 0.5
            }
        }
        Image {
            id: sourceItemR
            source: "assets/signal_r.png"
            layer.enabled: true
            width: parent.height - 10
            height: parent.height - 10
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
    Rectangle {
        id: shifterLightBox
        height: 0.05 * parent.height
        width: clShiftPoint > 0 ? numLeds * height : 0.1 * parent.width
        color: "#1F1F1F"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: parent.height * 0.025
        radius: height / 5
        border.color: "#292929"
        border.width: 1
        // Repeater to create an array of shift lights
        Repeater {
            model: numLeds
            Rectangle {
                width: clShiftPoint > 0 ? parent.height * 0.8 : parent.width * 0.8
                height: parent.height * 0.8
                radius: width / 2
                color: clShiftPoint > 0 ? (vRpm > clShiftPoint ? "#CF0404" : "#1F0505") : (vShowLights.includes("DL_SHIFT") ? "#CF0404" : "#1F0505")
                // Position each circle in a horizontal line
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: (index - (numLeds - 1) / 2) * (width * 1.1)
                anchors.verticalCenter: parent.verticalCenter
                border.color: "#252525"
                border.width: 1
            }
        }
    }
    // Settings Page Loader
    Loader {
        id: pageLoader
        anchors.fill: parent
        onItemChanged: {
            if (pageLoader.item) {
                // Connect the settingsChanged signal from SettingsPage.qml
                pageLoader.item.settingsChanged.connect(updateSettings)
            }
        }
    }
    function updateSettings(newPort, newShiftPoint) {
        console.log("Main Window: Hotplugging new settings...")
        if (ogPort != newPort) {
            console.log("Main Window: Different port, restarting udpListener...")
            udpListener.setPort(newPort)
            udpListener.start()
        }
        ogPort = newPort
        clShiftPoint = newShiftPoint
    }
    RoundButton {
        text: "Settings"
        width: 100
        height: 40
        radius: 5
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10

        onClicked: pageLoader.source = "SettingsPage.qml"
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
    property real clShiftPoint: settingsManager.loadSetting("shiftPoint",
                                                            "-1").toString()
    property int numLeds: clShiftPoint > 0 ? 9 : 1
    property int ogPort: settingsManager.loadSetting("ogPort",
                                                     "4444").toString()

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
}
