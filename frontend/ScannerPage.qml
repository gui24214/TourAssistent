import QtQuick
import QtQuick.Controls
import QtMultimedia
import Qt5Compat.GraphicalEffects
import QZXing
import "ApiHandler.js" as AH

Item {
    width: 400
    height: 600

    signal back()

    property string linguaSelecionadaQrCode: ""
    property var currentItem: null

    Timer {
        id: itemEncontrado
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            successEffect.visible = false
            getItem.visible = true
        }
    }

    Timer {
        id: itemEncontradoError
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            errorEffect.visible = false
            camera.active = true
            scannerPage.visible = true
            txtDetectQrCode.visible = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        Rectangle {
            id: closePage
            width: 40
            height: 40
            radius: 20
            color: "#1A1A1A"
            border.width: 1
            border.color: "#2A2A2A"
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 56

            Text {
                text: "x"
                font.pixelSize: 16
                font.family: interMedium.name
                color: "#9CA3AF"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: closePage.scale = 0.92
                onReleased: closePage.scale = 1.0
                onCanceled: closePage.scale = 1.0

                onClicked: {
                    camera.stop()
                    camera.active = false
                    back()
                    qrButton.visible = true
                    colbuttons.visible = true
                }
            }
        }

        Column {
            id: columnTxtQrCode
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 10

            Text {
                text: "QR Smart Access"
                font.family: interMedium.name
                font.pixelSize: 12
                font.letterSpacing: 2
                font.capitalization: Font.AllUppercase
                color: "#D4AF37"
            }

            Column {
                id: col2Buttons
                spacing: 5
                Text {
                    text: "Scan QR Code"
                    font.family: playfairSemiBold.name
                    font.pixelSize: 25
                    color: "white"
                }

                Text {
                    text: "Aponte para uma obra ou espaço do museu"
                    font.family: interRegular.name
                    font.pixelSize: 12
                    color: "#6b7280"
                }
            }
        }

        Camera {
            id: camera
            active: true
            focusMode: Camera.FocusModeAutoNear
        }

        Rectangle {
            id: scannerPage
            width: parent.width - 85
            height: (parent.height / 2) - 20
            anchors.centerIn: parent
            radius: 30
            visible:  true
            color: "transparent"

            CaptureSession {
                camera: camera
                videoOutput: videoOutput
            }

            Item {
                id: videoContainer
                anchors.fill: parent

                VideoOutput {
                    id: videoOutput
                    anchors.fill: parent
                    fillMode: VideoOutput.PreserveAspectCrop
                    visible: false
                }

                Rectangle {
                    id: maskShape
                    anchors.fill: parent
                    radius: 30
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: videoOutput
                    maskSource: maskShape
                }
            }

            QZXingFilter {
                id: zxingFilter
                videoSink: videoOutput.videoSink
                orientation: videoOutput.orientation
                decoder {
                    enabledDecoders: QZXing.DecoderFormat_QR_CODE

                    onTagFound: (tag) => {
                                    var cleanTag = tag.trim()

                                    AH.getData(linguaSelecionadaQrCode, function(dados) {

                                        var localPath = FileHelper.getLocalMediaFolder(linguaSelecionadaQrCode)
                                        var items = AH.getItems(dados, localPath)

                                        var foundItem = null

                                        for (var i = 0; i < items.length; i++) {

                                            var id = (items[i].documentId || "").trim()

                                            if (id === cleanTag) {
                                                foundItem = items[i]
                                                break
                                            }
                                        }

                                        if (foundItem) {

                                            currentItem = foundItem  //Guarda todos os items
                                            camera.active = false
                                            scannerPage.visible = false
                                            txtDetectQrCode.visible = false
                                            successEffect.visible = true
                                            successEffect.play()
                                        } else {
                                            errorEffect.visible = true
                                            errorEffect.playError()
                                            camera.active = false
                                            scannerPage.visible = false
                                            txtDetectQrCode.visible = false
                                        }
                                    })
                                }
                }

                Component.onDestruction: {
                    enabledDecoders = QZXing.DecoderFormat_None
                }
            }

            Rectangle {
                id: borderOverlay
                anchors.fill: parent
                radius: 30
                color: "transparent"
                border.width: 2
                border.color: "#D4AF37"
                clip: true

                Rectangle {
                    id: scanningLine
                    width: parent.width
                    height: 2

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: "#D4AF37" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    SequentialAnimation on y {
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 0
                            to: borderOverlay.height - scanningLine.height
                            duration: 1800
                            easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            from: borderOverlay.height - scanningLine.height
                            to: 0
                            duration: 1800
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
        }

        Text {
            id: txtDetectQrCode
            text: "A detectar QR code..."
            font.family: interRegular.name
            font.pixelSize: 13
            color: "#4B5563"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.6
            lineHeightMode: Text.ProportionalHeight
            anchors.top: scannerPage.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id: successEffect
            anchors.centerIn: parent
            visible: false
            opacity: 0
            scale: 0.6

            Rectangle {
                id: circle
                width: 120
                height: 120
                radius: 60
                anchors.centerIn: parent
                color: "black"
                border.color: "#D4AF37"
                border.width: 2

                Image {
                    source: "qrc:/images/images/checkmark.png"
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.top: circle.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "QR Reconhecido"
                    font.family: playfairSemiBold.name
                    font.pixelSize: 25
                    color: "white"
                }

                Text {
                    text: "A carregar conteúdo..."
                    font.family: interRegular.name
                    font.pixelSize: 12
                    color: "#D4AF37"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            SequentialAnimation on scale {
                id: popAnim
                running: false

                NumberAnimation { to: 1.2; duration: 200; easing.type: Easing.OutBack }
                NumberAnimation { to: 1.0; duration: 200; easing.type: Easing.OutBack }
            }

            SequentialAnimation {
                id: fadeIn
                running: false

                PropertyAnimation { target: successEffect; property: "opacity"; to: 1; duration: 150 }
            }

            function play() {
                visible = true
                fadeIn.start()
                popAnim.start()
                opacity = 1
                scale = 1
                itemEncontrado.restart()
            }
        }

        Item {
            id: errorEffect
            anchors.centerIn: parent
            visible: false
            opacity: 0
            scale: 0.6

            Rectangle {
                id: circleError
                width: 120
                height: 120
                radius: 60
                anchors.centerIn: parent
                color: "black"
                border.color: "Red"
                border.width: 2

                Image {
                    source: "qrc:/images/images/close.png"
                    anchors.centerIn: parent
                }
            }

            Column {
                anchors.top: circleError.bottom
                anchors.topMargin: 30
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    text: "QR Code Invalido"
                    font.family: playfairSemiBold.name
                    font.pixelSize: 25
                    color: "Red"
                }

                Text {
                    text: "Retornando..."
                    font.family: interRegular.name
                    font.pixelSize: 12
                    color: "#D4AF37"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            SequentialAnimation on scale {
                id: popAnimError
                running: false

                NumberAnimation { to: 1.2; duration: 200; easing.type: Easing.OutBack }
                NumberAnimation { to: 1.0; duration: 200; easing.type: Easing.OutBack }
            }

            SequentialAnimation {
                id: fadeInError
                running: false

                PropertyAnimation { target: successEffect; property: "opacity"; to: 1; duration: 150 }
            }

            function playError() {
                visible = true
                fadeInError.start()
                popAnimError.start()
                opacity = 1
                scale = 1
                itemEncontradoError.restart()
            }
        }

        Rectangle {
            id: getItem
            width: parent.width - 20
            height: parent.height - 20
            visible: false
            radius: 30
            anchors.top: columnTxtQrCode.bottom
            anchors.topMargin: 50
            color: "#111111"
            border.color: "#2a2a2a"
            border.width: 1

            ScrollView {
                anchors.fill: parent
                anchors.margins: 15

                Column {
                    width: parent.width
                    spacing: 15

                    // IMAGE PRINCIPAL
                    Image {
                        source: currentItem ? currentItem.coverUrlItem : ""
                        width: parent.width
                        height: 180
                        fillMode: Image.PreserveAspectCrop

                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 0.8; color: "#2e2e2e" }
                                GradientStop { position: 1.0; color: "#111111" }
                            }
                        }
                    }

                    // TITLE
                    Text {
                        text: currentItem ? currentItem.nameItem : ""
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                        wrapMode: Text.WordWrap
                    }

                    // DESCRIPTION
                    Text {
                        text: currentItem ? currentItem.descriptionItem : ""
                        font.pixelSize: 13
                        color: "#6b7280"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }

                    Rectangle {
                        id: recAudio
                        width: parent.width
                        height: 50
                        radius: 10
                        border.width: 0.5
                        border.color: "#2a2a2a"
                        color: "#1a1a1a"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 20

                            Rectangle {
                                id: playPauseButtonItem
                                width: 30
                                height: 30
                                radius: width / 2
                                color: "#2a2a2a"

                                property bool isPlaying: false

                                Image {
                                    id: imgPlayAudioItem
                                    source: "qrc:/images/images/PlayButton.png"
                                    width: 10
                                    height: 10
                                    visible: true
                                    anchors.centerIn: parent
                                }

                                Image {
                                    id: pouseButtonItem
                                    source: "qrc:/images/pouse.png"
                                    width: 20
                                    height: 20
                                    visible: false
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(imgPlayAudioItem.visible) {
                                            imgPlayAudioItem.visible = false
                                            pouseButtonItem.visible = true
                                        } else {
                                            imgPlayAudioItem.visible = true
                                            pouseButtonItem.visible = false
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: recAudio.width / 2
                                height: 3
                                color: "#2a2a2a"
                                anchors.verticalCenter: parent.verticalCenter

                                Rectangle {
                                    width: 100
                                    height: 3
                                    color: "#C89B3C"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    Item {
                        id: margem
                        width: parent.width
                        height: 50
                    }

                    Rectangle {
                        id: recVerMap
                        width: parent.width - 20
                        height: 50
                        radius: 12
                        color: "#1a1a1a"
                        border.width: 1
                        border.color: "#D4AF37"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: txtVerMap
                            text: "VER NO MAPA"
                            anchors.centerIn: parent
                            font.pixelSize: 12
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 1.5
                            font.family: interMedium.name
                            color: "#D4AF37"
                        }
                    }
                }
            }
        }
    }

    FontLoader {
        id: playfairSemiBold
        source: "qrc:/fonts/PlayfairDisplay-SemiBold.ttf"
    }

    FontLoader {
        id: playfairMedium
        source: "qrc:/fonts/PlayfairDisplay-Medium.ttf"
    }

    FontLoader {
        id: interRegular
        source: "qrc:/fonts/Inter_18pt-Regular.ttf"
    }

    FontLoader {
        id: interMedium
        source: "qrc:/fonts/Inter_18pt-Medium.ttf"
    }

    FontLoader {
        id: interSemiBold
        source: "qrc:/fonts/Inter_24pt-SemiBold.ttf"
    }
}
