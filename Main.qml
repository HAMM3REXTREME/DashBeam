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
                text: "Speed: " + vSpeed.toFixed(
                          1) + " km/h\nThrottle: " + (100*vThrottle).toFixed(
                          0) + "%\nTurbo: " + vTurbo.toFixed(
                          1) + ((clShiftPoint <= vRpm) ? "\nSHIFT" : "")
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

    TextField {
        id: portInput
        anchors.bottom: parent.bottom
        text: "4444"
        placeholderText: "Port"
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        width: 75
        height: 40
        // Styling for a dark theme
        color: "#FFFFFF"
        placeholderTextColor: "#A0A0A0"
        background: Rectangle {
            color: "#333333"
            radius: 5
            border.color: "#555555"
            border.width: 1
        }
    }
    Rectangle {
        id: indicators
        width: 0.5 * parent.width
        height: 0.1 * parent.height
        color: "#1F1F1F"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 20
        radius: height/5
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
        width: numLeds*height
        color: "#1F1F1F"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 10
        radius: height/5
        border.color: "#292929"
        border.width: 1
        // Repeater to create an array of shift lights
        Repeater {
            model: numLeds
            Rectangle {
                width: parent.height * 0.8
                height: width
                radius: width / 2
                color: clShiftPoint > 0 ? (vRpm > clShiftPoint ? "#CF0404" : "#1F0505") : (vShowLights.includes(
                                                                                               "DL_SHIFT") ? "#CF0404" : "#1F0505")
                // Position each circle in a horizontal line
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: (index - (numLeds - 1) / 2) * (width + 5)
                anchors.verticalCenter: parent.verticalCenter
                border.color: "#252525"
                border.width: 1
            }
        }
    }
    Rectangle {
        id: ipBox
        width: ipText.implicitWidth
        height: ipText.implicitHeight
        color: "#1F1F1F"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        radius: 5
        border.color: "#292929"
        border.width: 1
        Text {
            id: ipText
            width: parent.width
            height: parent.height
            anchors.centerIn: parent.centerIn
            text: "Your IP address:\n" + (networkInfo ? networkInfo.ipAddresses : "No IP addresses available")
            wrapMode: TextArea.Wrap
            color:  "#FFFFFF"
        }
    }
    // Timer for inactivity detection
    Timer {
        id: inactivityTimer
        interval: 10 * 1000  // milliseconds
        running: false
        repeat: false  // Run once after the specified time
        onTriggered: {
            // Hide elements after inactivity
            ipBox.visible = false
            portStart.visible = false
            portInput.visible = false
        }
    }
    MouseArea {
        id: globalMouseArea
        anchors.fill: parent
        onClicked: {
            // Reset the timer and show elements on click anywhere
            inactivityTimer.start()
            ipBox.visible = true
            portStart.visible = true
            portInput.visible = true
        }
    }

    Button {
        text: "..."
        font.pixelSize: 24
        width: 45
        height: 45
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20

        onClicked: menuPopup.open()
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
    property real clShiftPoint: -1
    property int numLeds: clShiftPoint > 0 ? 9 : 1

    // Connect to C++ signal for a packet
    Connections {
        target: udpListener
        onOutGaugeUpdated: function (data) {
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
