import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    // TODO: DO NOT USE CONDITIONAL BINDINGS FOR OPTIONS, USE STATES
    id: rpmBar
    property bool horizontal: true
    property bool topLabels: true // Draw labels on top (right if not a horizontal bar)
    color: "#292929"
    property color tickColor: "#FEFEFEFE"
    property color labelFontColor: "#FEFEFE"
    property real maxValue: 9
    property real fontFactor: 1
    property real redlineValue: 8
    property real tickStep: 0.1
    property int labelTickEvery: 10
    property int bigTickEvery: 5
    property real value: 0.0
    property real barEndThickness: 0.0020
    property real barEndLength: 1.5
    property string tickFontName: "sans-serif"
    states: [
        State {
            name: "verticalLeft"
            when: !horizontal && !topLabels
            AnchorChanges {
                target: barFillRedline
                anchors.bottom: undefined
                anchors.top: undefined
                anchors.right: parent.right
                anchors.left: undefined
            }
            PropertyChanges {
                target: barFillEnd
                width:  barEndLength * parent.width
                height: barEndThickness * parent.height
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: barFill.top
            }
            PropertyChanges {
                target: barFillRedline
                width: parent.width * 0.25
                height: ((rpmBar.maxValue - rpmBar.redlineValue) / rpmBar.maxValue) * parent.height
            }
            PropertyChanges {
                target: barFill
                width: parent.width
                height: (rpmBar.value / rpmBar.maxValue) * parent.height
            }
            PropertyChanges {
                target: rpmBar
                anchors.rightMargin: height + Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
            }
        },
        State {
            name: "verticalRight"
            when: !horizontal && topLabels
            AnchorChanges {
                target: barFillRedline
                anchors.bottom: undefined
                anchors.top: undefined
                anchors.right: undefined
                anchors.left: parent.left
            }
            PropertyChanges {
                target: barFillEnd
                width:  barEndLength * parent.width
                height: barEndThickness * parent.height
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: barFill.top
            }
            PropertyChanges {
                target: barFillRedline
                width: parent.width * 0.25
                height: ((rpmBar.maxValue - rpmBar.redlineValue) / rpmBar.maxValue) * parent.height
            }
            PropertyChanges {
                target: barFill
                width: parent.width
                height: (rpmBar.value / rpmBar.maxValue) * parent.height
            }
            PropertyChanges {
                target: rpmBar
                anchors.leftMargin: height + Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                anchors.topMargin: 0
                anchors.bottomMargin: 0
                anchors.rightMargin: 0
            }
        },
        State {
            name: "horizontalTop"
            when: horizontal && topLabels
            PropertyChanges {
                target: rpmBar
                anchors.topMargin: height + Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                anchors.rightMargin: 0
            }
            PropertyChanges {
                target: barFillEnd
                width:  barEndThickness * parent.width
                height: barEndLength * parent.height
                anchors.horizontalCenter: barFill.right
                anchors.verticalCenter: undefined
            }
            AnchorChanges {
                target: barFillRedline
                anchors.bottom: parent.bottom
                anchors.top: undefined
                anchors.right: parent.right
                anchors.left: undefined
            }
            PropertyChanges {
                target: barFill
                width: (rpmBar.value / rpmBar.maxValue) * parent.width
                height: parent.height
            }
            PropertyChanges {
                target: barFillRedline
                height: parent.height * 0.25
                width: ((rpmBar.maxValue - rpmBar.redlineValue) / rpmBar.maxValue) * parent.width
            }
        },
        State {
            name: "horizontalBottom"
            when: horizontal && !topLabels
            PropertyChanges {
                target: rpmBar
                anchors.bottomMargin: height + Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                anchors.leftMargin: 0
                anchors.topMargin: 0
                anchors.rightMargin: 0
            }
            PropertyChanges {
                target: barFillEnd
                width:  barEndThickness * parent.width
                height: barEndLength * parent.height
                anchors.horizontalCenter: barFill.right
                anchors.verticalCenter: undefined
            }
            AnchorChanges {
                target: barFillRedline
                anchors.bottom: undefined
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: undefined
            }
            PropertyChanges {
                target: barFill
                width: (rpmBar.value / rpmBar.maxValue) * parent.width
                height: parent.height
            }
            PropertyChanges {
                target: barFillRedline
                height: parent.height * 0.25
                width: ((rpmBar.maxValue - rpmBar.redlineValue) / rpmBar.maxValue) * parent.width
            }
        }
    ]
    Rectangle {
        id: barFillRedline
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: 0.1
        }
        color: "#a20b00"
    }
    Rectangle {
        id: barFill
        anchors.bottom: parent.bottom // Doesn't matter too much - 100% parent width anyways
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: 0.1
        }
        color: rpmBar.value >= rpmBar.redlineValue ? "#b60c00" : "#750000"
    }
    Rectangle {
        id: barFillEnd
        color: "#ee0000"
        // barEndThickness is a smaller factor than barEndLength, so basically swap them in case of vertical bars.
        //width: rpmBar.horizontal ? barEndThickness * parent.width : barEndLength * parent.width
        //height: rpmBar.horizontal ? barEndLength * parent.height : barEndThickness * parent.height
        // anchor the 'across' center to the barFill's 'moving' end. Differs for horizontal and vertical bars.
        //anchors.horizontalCenter: rpmBar.horizontal ? barFill.right : undefined
        // anchors.verticalCenter: rpmBar.horizontal ? undefined : barFill.top
        // horizontal bar, labels on top --> start from parent.bottom
        anchors.bottom: rpmBar.horizontal ? (rpmBar.topLabels ? parent.bottom : undefined) : undefined
        // horizontal bar, labels on bottom --> start from parent.top
        anchors.top: rpmBar.horizontal ? (rpmBar.topLabels ? undefined : parent.top) : undefined
        // vertical bar, labels on top (right) --> start from parent.left
        anchors.left: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? parent.left : undefined)
        // vertical bar, labels on bottom (left) --> start from parent.right
        anchors.right: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? undefined : parent.right)
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: 0.1
        }
    }
    Repeater {
        model: Math.floor(rpmBar.maxValue / rpmBar.tickStep) + 1
        Rectangle {
            id: tickMark
            // horizontal bar, labels on top --> start from parent.bottom
            anchors.bottom: rpmBar.horizontal ? (rpmBar.topLabels ? parent.bottom : undefined) : undefined
            // horizontal bar, labels on bottom --> start from parent.top
            anchors.top: rpmBar.horizontal ? (rpmBar.topLabels ? undefined : parent.top) : undefined
            // vertical bar, labels on top (right) --> start from parent.left
            anchors.left: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? parent.left : undefined)
            // vertical bar, labels on bottom (left) --> start from parent.right
            anchors.right: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? undefined : parent.right)
            // different (inversed) width and heights of tick lines depending on if the bar is horizontal or vertical.
            width: rpmBar.horizontal ? (index % rpmBar.bigTickEvery === 0 ? barEndThickness * parent.width : 1) : (index % rpmBar.bigTickEvery === 0 ? 1.25 : 0.25) * parent.width
            height: rpmBar.horizontal ? (index % rpmBar.bigTickEvery === 0 ? 1.25 : 0.25) * parent.height : (index % rpmBar.bigTickEvery === 0 ? 2 : 1)
            color: rpmBar.tickColor
            // horizontal bars --> arrange ticks on the x axis
            x: rpmBar.horizontal ? (index / (rpmBar.maxValue / rpmBar.tickStep)) * parent.width : 0
            // vertical bars --> arrange ticks on the y axis
            y: rpmBar.horizontal ? 0 : (1 - (index / (rpmBar.maxValue / rpmBar.tickStep))) * parent.height
            Text {
                id: tickLabel
                text: index * rpmBar.tickStep
                visible: index % rpmBar.labelTickEvery === 0 ? true : false
                color: rpmBar.labelFontColor
                font.pixelSize: Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                font.family: tickFontName
                // horizontal bar, labels on top --> be above parent.top
                anchors.bottom: rpmBar.horizontal ? (rpmBar.topLabels ? parent.top : undefined) : undefined
                // horizontal bar, labels on bottom --> be below parent.bottom
                anchors.top: rpmBar.horizontal ? (rpmBar.topLabels ? undefined : parent.bottom) : undefined
                // Center text horizontally for a horizontal bar and vertically for a vertical bar
                anchors.horizontalCenter: rpmBar.horizontal ? parent.horizontalCenter : undefined
                anchors.verticalCenter: rpmBar.horizontal ? undefined : parent.verticalCenter
                // vertical bar, labels on top (right) --> our left side should touch parent.right (by touching I mean anchored to)
                anchors.left: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? parent.right : undefined)
                // vertical bar, labels on bottom (left) --> our right side should touch parent.left
                anchors.right: rpmBar.horizontal ? undefined : (rpmBar.topLabels ? undefined : parent.left)
            }
        }
    }
}
