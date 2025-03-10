import QtQuick
import QtQuick.Controls
import QtQuick.Effects
// PROTOTYPE
Rectangle {
    id: box
    width: parent.width
    height: parent.height
    color: "#06060700"
    anchors.centerIn: parent
    clip: true
    property string textBox: "0"
    property real tDuration: 100
    onTextBoxChanged: {
        var visibleVal = parseInt(textB.text)
                textA.text = textB.text
                textB.text = box.textBox
        if (parseInt(box.textBox) > visibleVal){
            slideToLeftA.start()
            collapseA.start()
            slideFromRightB.start()
            expandB.start()
        } else if (parseInt(box.textBox) < visibleVal){
            slideToRightA.start()
            collapseA.start()
            slideFromLeftB.start()
            expandB.start()
        }

    }
    Text {
        id: textA
        text: "0"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: parent.height / 2
        font.family: uiFont.name
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        PropertyAnimation {
             id: collapseA
             target: textA
             property: "scale"
             from: 1
             to: 0
             duration: tDuration
             easing.type: Easing.InOutQuad
         }

         PropertyAnimation {
             id: expandA
             target: textA
             property:"scale"
             from: 0
             to: 1
             duration: tDuration
             easing.type: Easing.InOutQuad
         }
        PropertyAnimation {
            id: slideToLeftA
            target: textA
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: -box.width/2
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: slideFromRightA
            target: textA
            property:"anchors.horizontalCenterOffset"
            from: box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            id: slideToRightA
            target: textA
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: box.width/2
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: slideFromLeftA
            target: textA
            property:"anchors.horizontalCenterOffset"
            from: -box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

    }
    Text {
        id: textB
        text: "0"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: parent.height / 2
        font.family: uiFont.name
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        PropertyAnimation {
             id: collapseB
             target: textB
             property: "scale"
             from: 1
             to: 0
             duration: tDuration
             easing.type: Easing.InOutQuad
         }

         PropertyAnimation {
             id: expandB
             target: textB
             property:"scale"
             from: 0
             to: 1
             duration: tDuration
             easing.type: Easing.InOutQuad
         }
        PropertyAnimation {
            id: slideToLeftB
            target: textB
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: -box.width/2
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: slideFromRightB
            target: textB
            property:"anchors.horizontalCenterOffset"
            from: box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            id: slideToRightB
            target: textB
            property: "anchors.horizontalCenterOffset"
            from: 0
            to: box.width/2
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

        PropertyAnimation {
            id: slideFromLeftB
            target: textB
            property:"anchors.horizontalCenterOffset"
            from: -box.width/2
            to: 0
            duration: tDuration
            easing.type: Easing.InOutQuad
        }

    }
    // // Button to change text and trigger the animation
    // Button {
    //     text: "Downshift"
    //     anchors.bottom: parent.bottom
    //     anchors.left: parent.left
    //     onClicked: {
    //         box.textBox = parseInt(box.textBox)-1;
    //     }
    // }
    // Button {
    //     text: "Upshift"
    //     anchors.bottom: parent.bottom
    //     anchors.right: parent.right
    //     onClicked: {
    //         box.textBox = parseInt(box.textBox)+1;
    //     }
    // }

}
