import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Dialogs

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "DashBeam - Settings"

    signal portChanged(int port)
    signal shiftPointChanged(real clShiftPoint)

    //Material.theme: Material.Dark
    property real clShiftPoint: -1
    property int ogPort: 4444

    onClosing: close => {
                   close.accepted = false // Prevents the default close action
                   pageLoader.source = ""
               }
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#191919"
        anchors.centerIn: parent

        Flickable {
            id: flickable
            anchors.fill: parent
            clip: true // Ensures content doesn't overflow outside
            contentWidth: parent.width
            contentHeight: columnLayout.height
            flickableDirection: Flickable.VerticalFlick // Enables vertical scrolling
            ScrollBar.vertical: ScrollBar {
                parent: flickable.parent
                anchors.top: flickable.top
                anchors.left: flickable.right
                anchors.bottom: flickable.bottom
            }

            Column {
                id: columnLayout
                width: parent.width
                spacing: 20
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 10

                RoundButton {
                    text: "Back"
                    width: 80
                    height: 40
                    radius: 5
                    onClicked: {
                        pageLoader.source = ""
                    }
                }
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
                TextField {
                    id: portInput
                    text: settingsManager.loadSetting("ogPort",
                                                      "4444").toString()
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
                    onTextChanged: {
                        var port = parseInt(portInput.text)
                        if (port && port > 0 && port <= 65535) {
                            var newPort = parseFloat(text)
                            if (ogPort !== newPort) {
                                console.log("Different port number now...")
                                portChanged(newPort)
                            }
                            ogPort = newPort
                            settingsManager.saveSetting("ogPort", ogPort)
                        } else {
                            console.log("Invalid port number.")
                        }
                    }
                }
                Text {
                    text: "Client side shift lights/Redline RPM - Enter -1 for off"
                    color: "white"
                    font.pixelSize: 16
                }
                TextField {
                    id: inputShiftPoint
                    text: settingsManager.loadSetting("shiftPoint",
                                                      "-1").toString()
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
                    onTextChanged: {
                        if (!isFinite(text)) {
                            console.log("Invalid Redline number!")
                        } else {
                            var newClShiftPoint = parseFloat(text)
                            if (clShiftPoint !== newClShiftPoint) {
                                shiftPointChanged(newClShiftPoint)
                                console.log("Different shift point now...")
                            }
                            clShiftPoint = newClShiftPoint
                            settingsManager.saveSetting("shiftPoint",
                                                        clShiftPoint)
                        }
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
}
