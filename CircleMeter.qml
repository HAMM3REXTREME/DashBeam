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
    property int radius: 150 // Radius of the meter
    property color backgroundColorUpper: "#191919" // Background gradient upper color
    property color backgroundColorBottom: "#292929" // Background gradient lower color
    property color screenBackground: "#242426" // Middle section's screen color (top end of gradient)
    property color borderStrokeColor: "#f4f0e6" // Stroke color for the border of the meter
    property color tickColor: "#f4f0e6" // Stroke color for the tick marks
    property color tickColorRedline: "#FF0000" // Color for the tick marks at or after the redline
    property color labelFontColor: "#f4f0e6" // Color of the labels
    property color middleFontColor: "#f4f0e6" // Color of the middle text
    property color needleColor: "red"
    property color arcColor: "#9F0A0A"
    property color arcColorRedline: "#bf0909"
    property real needleValue: 0 // Set your rpm here
    property real needleWidth: radius / 40
    property real startAngle: 180 // Angle in degrees to start labelling (and the needle's 0 position)
    property real redline: 99999.9
    property bool repaint: false // Set to true to request a repaint for all canvas components
    property bool showScreen: true // Show the middle part or not
    property string tickFontName: "sans-serif"
    property string middleFontName: "monospace" // Font name for the middle display
    property real middleFontSize: radius / 5
    property string middleText: "" // Rich text in the middle display
    property bool blurLayer: false // 'Cinematic' blur thing
    property real blurValue: radius / 90000

    property real ghostRotation: 0 // Ghost needle rotation (don't set this manually, a timer will make the ghost needle lag automatically)

    Connections {
        function onNeedleValueChanged() {
            revArc.requestPaint()
        }
        function onRedlineChanged() {
            circleMarks.requestPaint()
        }
        // Manually request repaint...
        function onRepaintChanged() {
            circleMarks.requestPaint()
            revArc.requestPaint()
            repaint = false
        }
    }
    Rectangle {
        id: backgroundCircle
        width: dial.radius * 2
        height: dial.radius * 2
        anchors.centerIn: parent
        radius: dial.radius
        gradient: Gradient {
            stops: [
                GradientStop {
                    position: 0
                    color: backgroundColorUpper
                },
                GradientStop {
                    position: 1
                    color: backgroundColorBottom
                }
            ]
        }
        layer.enabled: blurLayer
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: blurValue
        }
        border.color: borderStrokeColor
        border.width: radius / 100
    }
    Canvas {
        id: revArc
        width: parent.width
        height: parent.height
        rotation: startAngle - 90
        layer.enabled: blurLayer
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: blurValue
        }
        onPaint: {
            var ctx = getContext("2d")
            var endAngleRad = (needle.rotation - startAngle) * (Math.PI / 180)
            ctx.clearRect(0, 0, width, height)
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, 0.65 * radius, 0, endAngleRad)
            ctx.lineWidth = radius / 20
            ctx.strokeStyle = needleValue >= redline ? arcColorRedline : arcColor
            ctx.stroke()
        }
    }

    Canvas {
        id: circleMarks
        width: parent.width
        height: parent.height
        layer.enabled: blurLayer
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: blurValue
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            // Draw the circular background
            ctx.beginPath()
            ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2)
            ctx.lineWidth = radius / 100
            ctx.strokeStyle = borderStrokeColor
            ctx.stroke()
            // Draw the alternating long and short ticks
            for (var i = 0; i < tickCount; i++) {
                var angle = (startAngle * (Math.PI / 180)) - (Math.PI / 2) + (Math.PI * 2 / tickDivide) * i
                var tickLength = (i % longTickEvery === 0) ? longTickLength : shortTickLength
                var startX = width / 2 + Math.cos(angle) * (radius - tickLength)
                var startY = height / 2 + Math.sin(angle) * (radius - tickLength)
                var endX = width / 2 + Math.cos(angle) * (0.985 * radius)
                var endY = height / 2 + Math.sin(angle) * (0.985 * radius)

                ctx.beginPath()
                ctx.moveTo(startX, startY)
                ctx.lineTo(endX, endY)
                ctx.lineWidth = radius / 75
                ctx.strokeStyle = (i * tickStep) < redline ? tickColor : tickColorRedline
                ctx.stroke()

                // Draw labels
                if (i % labelSkipEvery == 0) {
                    var labelX = width / 2 + Math.cos(angle) * (radius - longTickLength - labelFontSize)
                    var labelY = height / 2 + Math.sin(angle) * (radius - longTickLength - labelFontSize) + labelFontSize / 6 // Visual offset
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
        anchors.horizontalCenter: circleMarks.horizontalCenter
        anchors.bottom: circleMarks.verticalCenter
        transformOrigin: Item.Bottom
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: needleColor
            } // Tip (of the needle)
            GradientStop {
                position: 0.4
                color: "#771010"
            } // Base
        }
        rotation: ((dial.needleValue - dial.tickStart) / dial.tickStep) * (360 / dial.tickDivide) + dial.startAngle
    }
    MultiEffect {
        source: needle
        anchors.fill: needle
        blurEnabled: true
        blurMax: 64
        blur: 0.8
        anchors.horizontalCenter: circleMarks.horizontalCenter
        anchors.bottom: circleMarks.verticalCenter
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
        border.color: dial.borderStrokeColor // Stroke color
        border.width: 1
        radius: dial.width / 2 // Fully rounded (circle)
        anchors.centerIn: parent
        layer.enabled: blurLayer
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: blurValue
        }
        Text {
            anchors.centerIn: parent
            text: dial.middleText
            color: dial.middleFontColor
            font.pixelSize: dial.middleFontSize
            font.family: middleFontName
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            layer.enabled: blurLayer
            layer.effect: MultiEffect {
                blurEnabled: true
                blurMax: 64
                blur: blurValue
            }
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
}
