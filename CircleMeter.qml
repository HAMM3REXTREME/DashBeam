import QtQuick
import QtQuick.Effects

Item {
    // Avoid adding or subtracting absolute pixel values to help with scalability.
    // Better to be in terms of radius or other scalable properties.
    id: dial
    property int tickCount: 19 // Numbers of ticks visible
    property int tickDivide: 24 // How many ticks to divide by (like a pie)
    property real tickStep: 500 // Value change between every tick
    property real tickStart: 0 // Start labelling from
    property int labelSkipEvery: 2 // Skip labelling every nth tick
    property int labelFontSize: radius / 12 // Font size of labels
    property int longTickLength: radius / 8 // Pixel value of long ticks
    property int shortTickLength: radius / 16 // Pixel value of short ticks
    property int longTickEvery: 2 // Longer tick line every n
    property int radius: 150
    property color backgroundColorInner: "#232323"
    property color backgroundColorOuter: "#2F2F2F"
    property color screenBackground: "#202021"
    property color strokeColor: "#FFFFFF"
    property color tickColor: "#FFFFFF"
    property color tickColorRedline: "#FF0000"
    property color labelFontColor: "#FFFFFF"
    property color middleFontColor: "#FFFFFF"
    property color needleColor: "red"
    property real needleValue: 0
    property real needleWidth: radius / 40
    property real startAngle: 180
    property real redline: 99999.9
    property bool repaint: false
    property bool showScreen: true
    property string tickFontName: "sans-serif"
    property string middleFontName: "monospace"
    property real middleFontSize: radius / 5
    property string middleText: ""

    property real ghostRotation: 0

    Canvas {
        id: background
        width: parent.width
        height: parent.height
        onPaint: {
            var ctx = getContext("2d")
            // Gradient
            var grad = ctx.createRadialGradient(width / 2, height / 2,
                                                radius * 0.7, width / 2,
                                                height / 2, radius)
            grad.addColorStop(0, backgroundColorInner)
            grad.addColorStop(1, backgroundColorOuter)
            // Draw the circular background
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2)
            ctx.fillStyle = grad
            ctx.fill()
            ctx.lineWidth = radius / 50
            ctx.strokeStyle = strokeColor
            ctx.stroke()

            // Draw the alternating long and short ticks
            for (var i = 0; i < tickCount; i++) {
                var angle = (startAngle * (Math.PI / 180)) - (Math.PI / 2)
                        + (Math.PI * 2 / tickDivide) * i
                var tickLength = (i % longTickEvery === 0) ? longTickLength : shortTickLength
                var startX = width / 2 + Math.cos(angle) * (radius - tickLength)
                var startY = height / 2 + Math.sin(
                            angle) * (radius - tickLength)
                var endX = width / 2 + Math.cos(angle) * (0.98 * radius)
                var endY = height / 2 + Math.sin(angle) * (0.98 * radius)

                ctx.beginPath()
                ctx.moveTo(startX, startY)
                ctx.lineTo(endX, endY)
                ctx.lineWidth = radius / 75
                ctx.strokeStyle = (i * tickStep) < redline ? tickColor : tickColorRedline
                ctx.stroke()

                // Draw labels
                if (i % labelSkipEvery == 0) {
                    var labelX = width / 2 + Math.cos(
                                angle) * (radius - longTickLength - labelFontSize)
                    var labelY = height / 2 + Math.sin(
                                angle) * (radius - longTickLength - labelFontSize)
                            + labelFontSize / 6 // Visual offset
                    ctx.font = "bold " + labelFontSize + "px " + tickFontName
                    ctx.fillStyle = labelFontColor
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText((i * tickStep) + tickStart, labelX, labelY)
                }
            }
        }
    }

    Rectangle {
        id: needle
        smooth: true
        width: dial.needleWidth
        height: dial.radius * 0.85
        anchors.horizontalCenter: background.horizontalCenter
        anchors.bottom: background.verticalCenter
        transformOrigin: Item.Bottom
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: needleColor
            } // Tip (of the needle)
            GradientStop {
                position: 0.4
                color: "#000000AA"
            } // Base
        }
        rotation: ((dial.needleValue - dial.tickStart) / dial.tickStep)
                  * (360 / dial.tickDivide) + dial.startAngle
    }
    MultiEffect {
        source: needle
        anchors.fill: needle
        blurEnabled: true
        blurMax: 64
        blur: 0.8
        anchors.horizontalCenter: background.horizontalCenter
        anchors.bottom: background.verticalCenter
        transformOrigin: Item.Bottom
        rotation: dial.ghostRotation
    }

    Rectangle {
        id: middleSection
        clip: true
        visible: dial.showScreen
        width: dial.radius * 1.4 - longTickLength - labelFontSize
        height: dial.radius * 1.4 - longTickLength - labelFontSize
        color: dial.screenBackground
        border.color: dial.strokeColor // Stroke color
        border.width: 1
        radius: dial.width / 2 // Fully rounded (circle)
        anchors.centerIn: parent
        Text {
            anchors.centerIn: parent
            text: dial.middleText
            color: dial.middleFontColor
            font.pixelSize: dial.middleFontSize
            font.family: middleFontName
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
        }
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: dial.screenBackground
            } // top
            GradientStop {
                position: 1.0
                color: "#060607"
            } // bottom
        }
    }

    Timer {
        interval: 16 // Update every 50ms
        running: true
        repeat: true
        onTriggered: {
            // Smoothly interpolate the ghost rotation to follow the needle with a delay
            dial.ghostRotation = dial.ghostRotation + (needle.rotation - dial.ghostRotation) * 0.3
        }
    }

    Connections {
        function onBackgroundColorInnerChanged() {
            background.requestPaint()
        }

        function onBackgroundColorOuterChanged() {
            background.requestPaint()
        }

        function onRedlineChanged() {
            background.requestPaint()
        }

        // Manually request repaint...
        function onRepaintChanged() {
            background.requestPaint()
            repaint = false
        }
    }
}
