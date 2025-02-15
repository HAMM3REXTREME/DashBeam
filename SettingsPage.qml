import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Dialogs
import QtQuick.Controls.Material

Item {
    visible: true
    width: 1280
    height: 720
    Material.theme: Material.Dark
    property real clShiftPoint: settingsManager.loadSetting("shiftPoint", -1.0)
    property int ogPort: settingsManager.loadSetting("ogPort", 4444)
    property int numLeds: settingsManager.loadSetting("numLeds", 9)
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#191919"
        anchors.centerIn: parent
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#212121"
            width: parent.width
            height: parent.height - 1.5*backButton.height
            Flickable {
                id: flickable
                anchors.fill: parent
                clip: true // Ensures content doesn't overflow outside
                contentWidth: parent.width
                contentHeight: columnLayout.height
                flickableDirection: Flickable.VerticalFlick // Enables vertical scrolling
                ScrollBar.vertical: ScrollBar {
                    anchors.right: parent.right
                }

                Column {
                    id: columnLayout
                    width: parent.width
                    spacing: 20
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.margins: 10

                    Text {
                        text: "Options"
                        color: "white"
                        font.pixelSize: 24
                    }
                    Text {
                        text: "Port to listen on (Default: 4444)"
                        color: "white"
                        font.pixelSize: 16
                    }
                    Row {
                        TextField {
                            id: portInput
                            text: ogPort.toString()
                            placeholderText: "Port"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            width: 100
                            height: 40
                            color: "#FFFFFF"
                            placeholderTextColor: "#A0A0A0"
                            background: Rectangle {
                                color: "#333333"
                                radius: 10
                                border.color: "#555555"
                                border.width: 2
                            }
                        }
                        RoundButton {
                            text: "Set"
                            width: 80
                            radius: 10
                            height: 40
                            enabled: {
                                var port = parseInt(portInput.text)
                                if (!(port && port > 0 && port <= 65535)) {
                                    console.log("Settings: Invalid port number.")
                                    return false
                                } else if (port === ogPort) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                ogPort = parseInt(portInput.text)
                                settingsManager.saveSetting("ogPort", ogPort)
                            }
                        }
                    }
                    Text {
                        text: "Visual redline at RPM (-1 to disable)"
                        color: "white"
                        font.pixelSize: 16
                    }
                    Row {
                        TextField {
                            id: inputShiftPoint
                            text: clShiftPoint.toString()
                            placeholderText: "RPM"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            width: 100
                            height: 40
                            color: "#FFFFFF"
                            placeholderTextColor: "#A0A0A0"
                            background: Rectangle {
                                color: "#333333"
                                radius: 10
                                border.color: "#555555"
                                border.width: 2
                            }
                        }
                        RoundButton {
                            text: "Set"
                            width: 80
                            radius: 10
                            height: 40
                            enabled: {
                                var newShift = parseFloat(inputShiftPoint.text)
                                if (!isFinite(newShift)) {
                                    console.log("Settings: Invalid redline value.")
                                    return false
                                } else if (newShift === clShiftPoint) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                clShiftPoint = parseFloat(inputShiftPoint.text)
                                settingsManager.saveSetting("shiftPoint",
                                                            clShiftPoint)
                            }
                        }
                    }
                    Text {
                        text: "Number of LEDs on shifter"
                        color: "white"
                        font.pixelSize: 16
                    }
                    Row {
                        TextField {
                            id: inputNumleds
                            text: numLeds.toString()
                            placeholderText: "LEDs"
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                            width: 100
                            height: 40
                            color: "#FFFFFF"
                            placeholderTextColor: "#A0A0A0"
                            background: Rectangle {
                                color: "#333333"
                                radius: 10
                                border.color: "#555555"
                                border.width: 2
                            }
                        }
                        RoundButton {
                            text: "Set"
                            width: 80
                            radius: 10
                            height: 40
                            enabled: {
                                var newLeds = parseInt(inputNumleds.text)
                                if (newLeds < 1) {
                                    console.log("Settings: Invalid number of lights.")
                                    return false
                                } else if (newLeds === numLeds) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                numLeds = parseInt(inputNumleds.text)
                                settingsManager.saveSetting("numLeds",
                                                            numLeds)
                            }
                        }
                    }
                    Text {
                        text: "Client-side multicolor shift lights (Redline RPM needs to be >0)"
                        color: "white"
                        font.pixelSize: 16
                    }
                    CheckBox {
                        id: multiShiftCheck
                        text: "Always show client-side multicolored shift lights"
                        checked: settingsManager.loadSetting("isShift", false)
                        onCheckedChanged: {
                            settingsManager.saveSetting("isShift", checked)
                                                        console.log(settingsManager.loadSetting("isShift", false))
                        }
                    }
                    Text {
                        text: "Your IP Address:"
                        color: "white"
                        font.pixelSize: 24
                    }
                    Rectangle {
                        id: ipBox
                        width: ipText.implicitWidth + 20
                        height: ipText.implicitHeight + 20
                        color: "#333333"
                        radius: 10
                        border.color: "#555555"
                        border.width: 2

                        Text {
                            id: ipText
                            visible: false
                            anchors.centerIn: parent
                            anchors.margins: 10
                            font.pixelSize: 24
                            font.family: "monospace"
                            text: (networkInfo ? networkInfo.ipAddresses : "Can't find IP addresses")
                            wrapMode: TextArea.Wrap
                            color: "#FFFFFF"
                        }
                        Text {
                            id: ipTextHider
                            visible: true
                            anchors.centerIn: parent
                            anchors.margins: 10
                            font.pixelSize: 16
                            text: "Click to reveal"
                            wrapMode: TextArea.Wrap
                            color: "#FFFFFF"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ipText.visible = !ipText.visible
                                ipTextHider.visible = !ipTextHider.visible
                            }
                        }
                    }
                    Text {
                        text: "DashBeam alpha build"
                        color: "white"
                        font.pixelSize: 12
                    }
                    Item {
                        width: 1
                        height: flickable.height / 2 // Ensures smooth scrolling
                    }
                }
            }
        }
        RoundButton {
            id: backButton
            text: "Back"
            width: 80
            height: 40
            radius: 5
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 10
            onClicked: {
                settingsLoader.source = ""
            }
        }
    }
}
