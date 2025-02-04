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
            color: "#030305"
            radius: 4
            anchors.centerIn: parent
            FontLoader {
                id: uiFont
                source: "assets/Aldrich-Regular.ttf"
            }
            Text {
                anchors.centerIn: parent
                text: "Speed: " + speedValue.toFixed(1) + " km/h\nThrottle: " + throttleValue.toFixed(0) + "%\nTurbo: " + turboValue.toFixed(1)
                color: "white"
                font.pixelSize: 16
                font.family: uiFont.name
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle {
                id: throttleBar
                width:  10
                height: throttleValue/2
                color: "green"
                anchors.bottom: parent.bottom
                anchors.right: parent.right
            }
        }
    }

        // RPM Gauge (Left)
        CircleMeter {
        id: tacho
        radius: Math.min(parent.width/6, parent.height/2) - 10
        width: parent.width/3
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        tickStep: 0.5/5
        tickCount: 91
        tickDivide: 120
        longTickEvery: 5
        labelSkipEvery: 10
        needleValue: rpmValue/1000
        tickColor: "#FE8000"
        strokeColor: "#FE8000"
        }

        // Speed Gauge (Right)
        CircleMeter {
        id: speedo
        radius: Math.min(parent.width/6, parent.height/2) - 10
        width: parent.width/3
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
            placeholderText: "4444"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            width: 75

        }

        Button {
            text: "Start Listening"
            anchors.right: parent.right
            onClicked: {
                var port = parseInt(portInput.text);
                if (port && port > 0 && port <= 65535) {
                    udpListener.setPort(port);
                } else {
                    console.log("Invalid port number.");
                }
            }
        }

    property real rpmValue: 0.0
    property real speedValue: 0.0
    property real throttleValue: 0.0
    property real turboValue: 0.0
    property var ogFlags: []

    // Connect to C++ signal for a packet
    Connections {
        target: udpListener
        onOutGaugeUpdated: function(data) {
            rpmValue = data.rpm
            speedValue = data.speed * 3.6  // Converting speed from m/s to km/h
            throttleValue = data.throttle * 100
            turboValue = data.turbo
            ogFlags = data.flags
        }
    }
}
