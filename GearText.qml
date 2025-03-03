import QtQuick
import QtQuick.Controls
import QtQuick.Effects
// PROTOTYPE
Rectangle {
    id: box
    width: parent.width * 0.3
    height: parent.height * 0.4
    color: "#060607"
    radius: 4
    anchors.centerIn: parent
    border.color: "#292929"
    border.width: 1
    clip: true
    layer.enabled: true
    layer.effect: MultiEffect {
        blurEnabled: true
        blurMax: 64
        blur: 0.05
    }
    property string textBox: "0"
    property real tDuration: 100
    // Trigger the animation when the text changes
    onTextBoxChanged: {
        // Start the move animation whenever the text changes
        if (parseInt(box.textBox) > parseInt(animatedText.text)){
            moveAnimationUp.start()
        } else if (parseInt(box.textBox) < parseInt(animatedText.text)){
            moveAnimationDown.start()
        }
        moveAnimationScale.start()

    }
    Text {
        id: animatedText
        text: "0"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: parent.height / 2
        font.family: uiFont.name
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter

        PropertyAnimation {
            id: moveAnimationScale
            target: animatedText
            property: "scale"
            from: 1
            to: 0
            duration: tDuration
            onFinished: {
                // Reverse the animation after moving up
                reverseAnimationScale.start()
            }
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: reverseAnimationScale
            target: animatedText
            property:"scale"
            from: 0
            to: 1
            duration: tDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            id: moveAnimationUp
            target: animatedText
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: -box.width/2
            duration: tDuration
            onFinished: {
                animatedText.text = box.textBox
                // Reverse the animation after moving up
                reverseAnimationUp.start()
            }
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: reverseAnimationUp
            target: animatedText
            property:"anchors.horizontalCenterOffset"
            from: box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            id: moveAnimationDown
            target: animatedText
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: box.width/2
            duration: tDuration
            onFinished: {
                animatedText.text = box.textBox
                // Reverse the animation after moving up
                reverseAnimationDown.start()
            }
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: reverseAnimationDown
            target: animatedText
            property:"anchors.horizontalCenterOffset"
            from: -box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

    }
    // Button to change text and trigger the animation
    Button {
        text: "Downshift"
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        onClicked: {
            box.textBox = parseInt(box.textBox)-1;
        }
    }
    Button {
        text: "Upshift"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked: {
            box.textBox = parseInt(box.textBox)+1;
        }
    }

}
