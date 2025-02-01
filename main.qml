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
        color: "#292929"
        anchors.centerIn: parent

        // RPM Gauge (Left)
        CircleMeter {
        width: parent.width/2
        height: parent.height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        tickStep: 0.5
        needleValue: rpmValue/1000
        }

        // Speed Gauge (Right)
        CircleMeter {
        id: speedo
        width: parent.width/2
        height: parent.height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        needleValue: speedValue
        tickStep: 10
        tickCount: 27
        tickDivide: 35
        startAngle: 270
        }


        // Central Box for Info (Square box in the center)
        Rectangle {
            id: centerBox
            width: 200
            height: 100
            color: "#333"
            radius: 10
            anchors.centerIn: parent

            // Information Text in the center box
            Text {
                anchors.centerIn: parent
                text: "Speed: " + speedValue.toFixed(1) + " km/h\nThrottle: " + throttleValue.toFixed(0) + "%\nTurbo: " + turboValue.toFixed(1)
                color: "white"
                font.pixelSize: 16
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    Rectangle {
        id: thermometerFill
        width:  20 //parent.width
        height: throttleValue//(parent.height * throttleValue) / 100 // Height based on percentage value
        color: "green"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }



    // Bind properties to the C++ values
    property real rpmValue: 0.0
    property real speedValue: 0.0
    property real throttleValue: 0.0
    property real turboValue: 0.0

    // Connect to C++ signal for full packet
    Connections {
        target: udpListener
        onOutGaugeUpdated: function(data) {
            rpmValue = data.rpm
            speedValue = data.speed * 3.6  // Converting speed from m/s to km/h
            throttleValue = data.throttle * 100
            turboValue = data.turbo
        }
    }
}
