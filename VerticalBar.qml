import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects

Rectangle {
    id: verticalBar
    color: "#292929"
    Rectangle {
        id: barFill
        width: parent.width
        height: 0.5 * parent.height
        anchors.bottom: parent.bottom
        layer.enabled: true
        layer.effect: MultiEffect {
            saturation: vThrottle >= 1 ? 0.6 : 0.01
        }
    }
}
