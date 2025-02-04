import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Car Dashboard"

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
                text: "Speed: " + speedValue.toFixed(
                          1) + " km/h\nThrottle: " + throttleValue.toFixed(
                          0) + "%\nTurbo: " + turboValue.toFixed(
                          1) + ((clShiftPoint <= rpmValue) ? "\nSHIFT" : "")
                color: "white"
                font.pixelSize: 16
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                id: throttleBar
                width: 10
                height: throttleValue / 2
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
        needleValue: rpmValue / 1000
        tickColor: "#FE8000"
        strokeColor: "#FE8000"
        backgroundColorInner: showLights.includes(
                                  "DL_SHIFT") ? "#392424" : "#242424"
        redline: clShiftPoint / 1000
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
        needleValue: speedValue
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

    RoundButton {
        id: portStart
        width: 150
        height: 40
        radius: 5
        text: "Start Listening"
        anchors.left: portInput.right
        anchors.bottom: portInput.bottom
        onClicked: {
            var port = parseInt(portInput.text)
            if (port && port > 0 && port <= 65535) {
                udpListener.setPort(port)
            } else {
                console.log("Invalid port number.")
            }
        }
    }

    Rectangle {
        width: 0.5 * parent.width
        height: 0.1 * parent.height
        color: "#1F1F1F"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.margins: 20
        radius: 10
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
                saturation: showLights.includes("DL_SIGNAL_L") ? 1.0 : -1.0
                opacity: showLights.includes("DL_SIGNAL_L") ? 1.0 : 0.5
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
                saturation: showLights.includes("DL_SIGNAL_R") ? 1.0 : -1.0
                opacity: showLights.includes("DL_SIGNAL_R") ? 1.0 : 0.5
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
    property real rpmValue: 0.0
    property real speedValue: 0.0
    property real throttleValue: 0.0
    property real turboValue: 0.0
    property var ogFlags: []
    property var showLights: []

    // Client side options
    property real clShiftPoint: 7000.0

    // Connect to C++ signal for a packet
    Connections {
        target: udpListener
        onOutGaugeUpdated: function (data) {
            rpmValue = data.rpm
            speedValue = data.speed * 3.6 // Converting speed from m/s to km/h
            throttleValue = data.throttle * 100
            turboValue = data.turbo
            ogFlags = data.flags
            showLights = data.showLights
        }
    }
}
