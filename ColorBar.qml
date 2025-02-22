import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

Rectangle {
    id: colorBar
    property bool horizontal: false
    color: "#00000088"
    border.color: "#292929"
    border.width: 1
    property real value: 0.0
    property color fillColor: "#9f9f9f"
    Rectangle {
        id: barFill
        radius: colorBar.radius
        color: colorBar.fillColor
        width: horizontal ? colorBar.value * parent.width : parent.width
        height: horizontal ? parent.height : colorBar.value * parent.height
        anchors.bottom: parent.bottom
        layer.enabled: true
        layer.effect: MultiEffect {
            saturation: colorBar.value >= 1 ? 0.6 : 0.01
            blurEnabled: colorBar.value >= 1
            blurMax: 64
            blur: 0.1
        }
    }
}
