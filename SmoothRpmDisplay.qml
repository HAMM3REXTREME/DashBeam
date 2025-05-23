import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
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
    property color barFillColor: "#750000"
    property color barFillColorRedline: "#b60c00"
    states: [
        State {
            name: "verticalLeft"
            when: !horizontal && !topLabels
            AnchorChanges {
                target: barFillRedline
                anchors.bottom: undefined
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: undefined
            }
            PropertyChanges {
                target: barFillEnd
                width: barEndLength * parent.width
                height: barEndThickness * parent.height
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: barFill.top
            }
            AnchorChanges {
                target: barFillEnd
                anchors.bottom: undefined
                anchors.top: undefined
                anchors.left: undefined
                anchors.right: parent.right
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
                anchors.top: parent.top
                anchors.right: undefined
                anchors.left: parent.left
            }
            PropertyChanges {
                target: barFillEnd
                width: barEndLength * parent.width
                height: barEndThickness * parent.height
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: barFill.top
            }
            AnchorChanges {
                target: barFillEnd
                anchors.bottom: undefined
                anchors.top: undefined
                anchors.left: parent.left
                anchors.right: undefined
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
                width: barEndThickness * parent.width
                height: barEndLength * parent.height
                anchors.horizontalCenter: barFill.right
                anchors.verticalCenter: undefined
            }
            AnchorChanges {
                target: barFillEnd
                anchors.bottom: parent.bottom
                anchors.top: undefined
                anchors.left: undefined
                anchors.right: undefined
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
                width: barEndThickness * parent.width
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
            AnchorChanges {
                target: barFillEnd
                anchors.bottom: undefined
                anchors.top: parent.top
                anchors.left: undefined
                anchors.right: undefined
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
        anchors.bottom: parent.bottom // Doesn't matter too much - 100% of parent width anyways
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: 0.1
        }
        color: rpmBar.value >= rpmBar.redlineValue ? barFillColorRedline : barFillColor
    }
    Rectangle {
        id: barFillEnd
        color: "#ee0000"
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
            states: [
                State {
                    name: "verticalLeft"
                    when: !horizontal && !topLabels
                    AnchorChanges {
                        target: tickMark
                        anchors.bottom: undefined
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: parent.right
                    }
                    PropertyChanges {
                        target: tickMark
                        x: 0
                        y: (1 - (index / (rpmBar.maxValue / rpmBar.tickStep))) * parent.height
                    }
                    AnchorChanges {
                        target: tickLabel
                        anchors.bottom: undefined
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: parent.left
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: parent.verticalCenter
                    }
                },
                State {
                    name: "verticalRight"
                    when: !horizontal && topLabels
                    AnchorChanges {
                        target: tickMark
                        anchors.bottom: undefined
                        anchors.top: undefined
                        anchors.left: parent.left
                        anchors.right: undefined
                    }
                    PropertyChanges {
                        target: tickMark
                        x: 0
                        y: (1 - (index / (rpmBar.maxValue / rpmBar.tickStep))) * parent.height
                    }
                    AnchorChanges {
                        target: tickLabel
                        anchors.bottom: undefined
                        anchors.top: undefined
                        anchors.left: parent.right
                        anchors.right: undefined
                        anchors.horizontalCenter: undefined
                        anchors.verticalCenter: parent.verticalCenter
                    }
                },
                State {
                    name: "horizontalTop"
                    when: horizontal && topLabels
                    AnchorChanges {
                        target: tickMark
                        anchors.bottom: parent.bottom
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: undefined
                    }
                    PropertyChanges {
                        target: tickMark
                        x: (index / (rpmBar.maxValue / rpmBar.tickStep)) * parent.width
                        y: 0
                    }
                    AnchorChanges {
                        target: tickLabel
                        anchors.bottom: parent.top
                        anchors.top: undefined
                        anchors.left: undefined
                        anchors.right: undefined
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: undefined
                    }
                },
                State {
                    name: "horizontalBottom"
                    when: horizontal && !topLabels
                    AnchorChanges {
                        target: tickMark
                        anchors.bottom: undefined
                        anchors.top: parent.top
                        anchors.left: undefined
                        anchors.right: undefined
                    }
                    PropertyChanges {
                        target: tickMark
                        x: (index / (rpmBar.maxValue / rpmBar.tickStep)) * parent.width
                        y: 0
                    }
                    AnchorChanges {
                        target: tickLabel
                        anchors.bottom: undefined
                        anchors.top: parent.bottom
                        anchors.left: undefined
                        anchors.right: undefined
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: undefined
                    }
                }
            ]
            width: rpmBar.horizontal ? (index % rpmBar.bigTickEvery === 0 ? barEndThickness * parent.width : 1) : (index % rpmBar.bigTickEvery === 0 ? 1.25 : 0.25) * parent.width
            height: rpmBar.horizontal ? (index % rpmBar.bigTickEvery === 0 ? 1.25 : 0.25) * parent.height : (index % rpmBar.bigTickEvery === 0 ? 2 : 1)
            color: rpmBar.tickColor
            Text {
                id: tickLabel
                text: index * rpmBar.tickStep
                visible: index % rpmBar.labelTickEvery === 0 ? true : false
                color: rpmBar.labelFontColor
                font.pixelSize: Math.min(rpmBar.width, rpmBar.height) * rpmBar.fontFactor
                font.family: tickFontName
            }
        }
    }
}
