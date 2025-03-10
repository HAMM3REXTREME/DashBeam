import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Dialogs
import QtQuick.Controls.Material

// Must be loaded with Loader { id: settingsLoader }
Item {
    id: settingsPage
    visible: true
    width: 1280
    height: 720
    Material.theme: Material.Dark
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
            height: parent.height - 1.5 * backButton.height
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
                            text: AppSettings.listenPort.toString()
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
                                } else if (port === AppSettings.listenPort) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                AppSettings.listenPort = parseInt(portInput.text)
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
                            text: AppSettings.vRedline.toString()
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
                                } else if (newShift === AppSettings.vRedline) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                AppSettings.vRedline = parseFloat(inputShiftPoint.text)
                            }
                        }
                    }
                    Text {
                        text: "Number of LEDs on shift bar"
                        color: "white"
                        font.pixelSize: 16
                    }
                    Row {
                        TextField {
                            id: inputNumleds
                            text: AppSettings.shiftLightCount.toString()
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
                                if (newLeds < 1 | newLeds > 512) {
                                    console.log("Settings: Invalid number of lights.")
                                    return false
                                } else if (newLeds === AppSettings.shiftLightCount) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                AppSettings.shiftLightCount = parseInt(inputNumleds.text)
                            }
                        }
                    }
                    Text {
                        text: "Shift Light LEDs aspect ratio"
                        color: "white"
                        font.pixelSize: 16
                    }
                    Row {
                        TextField {
                            id: inputLightAspect
                            text: AppSettings.shiftLightAspect.toString()
                            placeholderText: "Ratio"
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
                                var newAspect = parseFloat(inputLightAspect.text)
                                if (!isFinite(newAspect)) {
                                    console.log("Settings: Invalid shift light aspect value.")
                                    return false
                                } else if (newAspect === AppSettings.shiftLightAspect) {
                                    return false
                                }
                                return true
                            }
                            onClicked: {
                                AppSettings.shiftLightAspect = parseFloat(inputLightAspect.text)
                            }
                        }
                    }
                    ColorDialog {
                        id: colorDialog
                        selectedColor: AppSettings.shiftLightColorAll
                        onAccepted: {
                            AppSettings.shiftLightColorAll = selectedColor
                        }
                    }
                    ShiftLights {
                        height: 0.025 * settingsPage.height
                        width: 0.025 * numLeds * parent.width * lightAspect
                        anchors.horizontalCenter: parent.horizontalCenter
                        shiftSingleOn: !AppSettings.enableClientLights
                        maxShiftPoint: AppSettings.vRedline
                        vehicleRpm: dummyRpmSlide.value
                        numLeds: AppSettings.shiftLightCount
                        shadeAll: AppSettings.shiftLightColorAll
                        lightAspect: AppSettings.shiftLightAspect
                    }
                    Slider {
                        id: dummyRpmSlide
                        from: 0
                        value: AppSettings.vRedline
                        to: AppSettings.vRedline
                    }
                    RoundButton {
                        text: "Change shift point color"
                        width: 200
                        radius: 10
                        height: 40
                        enabled: true
                        onClicked: {
                            colorDialog.open()
                        }
                    }
                    Text {
                        text: "Client-side multicolor shift lights (Redline RPM needs to be >0)"
                        color: "white"
                        font.pixelSize: 16
                    }
                    CheckBox {
                        id: multiShiftCheck
                        text: "Only show client-side multicolor lights (or nothing if redline = -1)"
                        checked: AppSettings.enableClientLights
                        onCheckedChanged: {
                            AppSettings.enableClientLights = checked
                        }
                    }
                    Text {
                        text: "Your IP Address:"
                        color: "white"
                        font.pixelSize: 24
                    }
                    Text {
                        text: "All IP addresses for this device. Use the correct one (accessible on your local network) in BeamNG settings."
                        color: "white"
                        font.pixelSize: 16
                    }
                    Rectangle {
                        id: ipBox
                        width: ipText.implicitWidth + 30
                        height: ipText.implicitHeight + 30
                        color: "#333333"
                        radius: 10
                        border.color: "#555555"
                        border.width: 2

                        MouseArea {
                            id: ipRevealer
                            anchors.fill: parent
                            onClicked: {
                                ipText.visible = !ipText.visible
                                ipTextHiddenMsg.visible = !ipTextHiddenMsg.visible
                            }
                        }
                        Text {
                            id: ipTextHiddenMsg
                            visible: true
                            anchors.centerIn: parent
                            anchors.margins: 10
                            font.pixelSize: 16
                            text: "Click to reveal"
                            wrapMode: TextArea.Wrap
                            color: "#FFFFFF"
                        }
                        TextEdit {
                            id: ipText
                            visible: false
                            readOnly: true
                            anchors.centerIn: parent
                            anchors.margins: 10
                            font.pixelSize: 20
                            font.family: "monospace"
                            text: (networkInfo ? networkInfo.ipAddresses : "Can't find IP addresses")
                            wrapMode: TextArea.Wrap
                            color: "#FFFFFF"
                        }
                    }
                    Text {
                        text: "DashBeam development preview"
                        color: "white"
                        font.pixelSize: 12
                    }
                    // Add some scrollability
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
