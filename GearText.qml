import QtQuick 2.15
import QtQuick.Controls 2.15
// PROTOTYPE
Rectangle {
    id: box
    width: 100
    height: 170
    color: "#292929"
    clip: true
    border.color : "white"
    border.width: 2
    radius: 45
    property string textBox: "0"
    // Trigger the animation when the text changes
    onTextBoxChanged: {
        // Start the move animation whenever the text changes
        if (parseInt(box.textBox) > parseInt(animatedText.text)){
            moveAnimationUp.start()
        } else if (parseInt(box.textBox) < parseInt(animatedText.text)){
            moveAnimationDown.start()
        }

    }
    Text {
        id: animatedText
        text: "0"
        font.pixelSize: 24
        anchors.centerIn: parent
        color: "white"

        // Animation for moving up and down
        PropertyAnimation {
            id: moveAnimationUp
            target: animatedText
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: -box.width/2
            duration: 75
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
            duration: 75
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            id: moveAnimationDown
            target: animatedText
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: box.width/2
            duration: 75
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
            duration: 75
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
