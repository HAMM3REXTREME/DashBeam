import QtQuick
import QtQuick.Effects

Item {
    id: dial
    property int tickCount: 19 // Numbers of ticks visible
    property int tickDivide: 24 // How many ticks to divide by (like a pie)
    property real tickStep: 500 // Value change between every tick
    property int labelSkipEvery: 2 // Skip labelling every nth tick
    property int radius: 150
    property color backgroundColor: "#2f2f2f"
    property color strokeColor: "#FFFFFF"
    property color tickColor: "#FFFFFF"
    property color needleColor: "red"
    property real needleValue: 0
    property real startAngle: 180;

    property real ghostRotation: 0

    Canvas {
        id: background
        width: parent.width
        height: parent.height
        onPaint: {
            var ctx = getContext("2d");

            // Draw the circular background
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2);
            ctx.fillStyle = backgroundColor;
            ctx.fill();
            ctx.lineWidth = 3;
            ctx.strokeStyle = strokeColor;
            ctx.stroke();

            // Draw the alternating long and short ticks
            for (var i = 0; i < tickCount; i++) {
                var angle = (startAngle*(Math.PI/180)) - (Math.PI/2) + (Math.PI * 2 / tickDivide) * i;
                var tickLength = (i % labelSkipEvery === 0) ? 20 : 10;
                var startX = width / 2 + Math.cos(angle) * (radius - tickLength);
                var startY = height / 2 + Math.sin(angle) * (radius - tickLength);
                var endX = width / 2 + Math.cos(angle) * radius;
                var endY = height / 2 + Math.sin(angle) * radius;

                ctx.beginPath();
                ctx.moveTo(startX, startY);
                ctx.lineTo(endX, endY);
                ctx.lineWidth = 2;
                ctx.strokeStyle = tickColor;
                ctx.stroke();

                // Draw labels
                if (i%labelSkipEvery==0){
                var labelX = width / 2 + Math.cos(angle) * (radius - 30);
                var labelY = height / 2 + Math.sin(angle) * (radius - 30);
                ctx.font = "bold 12px Roboto";
                ctx.fillStyle = tickColor;
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(i * tickStep, labelX, labelY);}
            }
        }

    }
    Rectangle {
        id: needle
        smooth: true
        width: 4
        height: dial.radius - 25
        color: needleColor
        anchors.horizontalCenter: background.horizontalCenter
        anchors.bottom: background.verticalCenter
        transformOrigin: Item.Bottom
        rotation: (dial.needleValue/dial.tickStep)*(360/dial.tickDivide) + dial.startAngle
    }
    MultiEffect {
        source: needle
        anchors.fill: needle
        blurEnabled: true
        blurMax: 64
        blur: 0.3
        anchors.horizontalCenter: background.horizontalCenter
        anchors.bottom: background.verticalCenter
        transformOrigin: Item.Bottom
        rotation: dial.ghostRotation
    }
    Timer {
        interval: 16 // Update every 50ms
        running: true
        repeat: true
        onTriggered: {
            // Smoothly interpolate the ghost rotation to follow the needle with a delay
            dial.ghostRotation = dial.ghostRotation + (needle.rotation - dial.ghostRotation) * 0.3;
        }
    }

}
