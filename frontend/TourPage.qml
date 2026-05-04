import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtMultimedia
import "ApiHandler.js" as AH

Item {
    id: root
    width: 400
    height: 600

    signal back()
    property string linguaSelecionadaTourPage: "pt"

    property var tourInfo: null
    property var tourInfoMap: null
    property var tourInfoItem: []

    property int contadorParagens: 1
    property int valorEstaticoStop: tourInfo ? tourInfo.totalStops : 0
    property int valorAtualStop: tourInfo ? tourInfo.totalStops : 0
    property int valorFinalStop: (valorAtualStop - (contadorParagens - 1)) || 1

    property var currentItem: (tourInfoItem.length > 0)
        ? tourInfoItem[Math.min(contadorParagens - 1, tourInfoItem.length - 1)]
        : null

    ListModel { id: modelMapasTour }
    ListModel { id: modelItensTour }

    Rectangle {
        anchors.fill: parent
        color: "white"

        // --- HEADER FIXO ---
        Text {
            id: txtnameTour
            text: tourInfo ? tourInfo.nameTour : ""
            font.family: "Sans-Serif"
            font.pixelSize: 10
            font.letterSpacing: 1.5
            font.capitalization: Font.AllUppercase
            color: "#9CA3AF"
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 35
        }

        Text {
            id: txtParagemContador
            text: "Paragem " + contadorParagens + " de " + (tourInfo ? tourInfo.totalStops : 0)
            font.pixelSize: 10
            font.family: "Sans-Serif"
            color: "#4B5563"
            font.letterSpacing: 1
            anchors.top: txtnameTour.bottom
            anchors.topMargin: 5
            anchors.left: parent.left
            anchors.leftMargin: 20
        }

        Rectangle {
            id: closePage
            width: 40
            height: 40
            radius: 50
            border.width: 0.5
            border.color: "#9CA3AF"
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top:parent.top
            anchors.topMargin: 30

            Text {
                text:"x"
                font.pixelSize: 18
                color: "#4B5563"
                font.family: "Sans-Serif"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    back()
                    recTours.visible = true
                }
            }
        }

        Rectangle {
            id: recProgressBar
            width: parent.width - 40
            height: 5
            radius: 20
            color: "#9CA3AF"
            anchors.top: closePage.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 20

            Rectangle {
                id: progressBar
                width: parent.width / valorFinalStop
                height: parent.height
                radius: parent.radius
                color: "#D4AF37"
                Behavior on width { NumberAnimation { duration: 200 } }
            }
        }

        Row {
            id: rowrecProgressBar
            anchors.top: recProgressBar.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 10

            Repeater {
                model: valorEstaticoStop
                delegate: Rectangle {
                    width: (contadorParagens - 1) === index ? 20 : 5
                    height: 5
                    radius: 50
                    color: (contadorParagens - 1) >= index ?  "#D4AF37" : "#9CA3AF"
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }
        }

        Flickable {
            id: scrollArea
            width: parent.width
            anchors.top: rowrecProgressBar.bottom
            anchors.topMargin: 10
            anchors.bottom: backStopTrue.top // Termina acima dos botões
            anchors.bottomMargin: 10
            contentHeight: contentColumn.height // Altura dinâmica baseada no conteúdo
            clip: true // Não deixa o conteúdo vazar para fora desta área
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: contentColumn
                width: parent.width
                spacing: 20
                bottomPadding: 20 // Espaço extra no final do scroll

                Item {
                    width: parent.width
                    height: 250 // Mesma altura da imagem + margem

                    Image {
                        id: imgItems
                        source: currentItem ? currentItem.coverUrlItem : ""
                        width: parent.width - 40
                        height: 250
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        anchors.horizontalCenter: parent.horizontalCenter

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: imgItems.width
                                height: imgItems.height
                                radius: 15
                            }
                        }
                    }

                    Text {
                        text: currentItem ? currentItem.nameItem : ""
                        font.pixelSize: 20
                        font.family: "Times New Roman"
                        font.weight: Font.Light
                        font.letterSpacing: 1.2
                        font.capitalization: Font.AllUppercase
                        color: "white"
                        renderType: Text.NativeRendering
                        anchors.left: imgItems.left
                        anchors.leftMargin: 20
                        anchors.bottom: imgItems.bottom
                        anchors.bottomMargin: 20
                    }
                }

                // Player de Áudio
                Rectangle {
                    id: recProgressBarAudio
                    width: parent.width - 40
                    height: 60
                    radius: 10
                    border.width: 0.5
                    border.color: "gray"
                    color: "#f7f7f7"
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: playPauseButton
                        width: 30
                        height: 30; radius: 15
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: "white"
                        border.width: 2
                        border.color: "#C89B3C"

                        Image {
                            source: "qrc:/images/images/PlayButton.png"
                            width: 10
                            height: 10
                            anchors.centerIn: parent
                        }
                    }

                    Column {
                        id: columnAudio
                        width: parent.width - playPauseButton.width - 60
                        anchors.left: playPauseButton.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Row {
                            spacing: 8

                            Image {
                                source: "qrc:/images/images/audioIcon.png"
                                width: 13
                                height:13
                            }

                            Text {
                                text: "AUDIO-GUIA"
                                font.pixelSize: 10
                                color: "#9CA3AF"
                                font.letterSpacing: 1.5
                            }
                        }

                        Rectangle {
                            id: progressBarAudio
                            width: parent.width
                            height: 5
                            color: "#9CA3AF"
                            Rectangle {
                                width: 0
                                height: parent.height
                                color: "#D4AF37"
                            }
                        }

                        RowLayout {
                            width: parent.width

                            Text {
                                text: "0:00"
                                font.pixelSize: 10
                                color: "#9CA3AF"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "2:30"
                                font.pixelSize: 10
                                color: "#9CA3AF"
                                anchors.right: parent.right
                            }
                        }
                    }
                }

                Text {
                    text: currentItem ? currentItem.descriptionItem : ""
                    width: parent.width - 40
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 14
                    font.family: interRegular.name
                    color: "#4B5563"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    lineHeight: 1.2
                    lineHeightMode: Text.ProportionalHeight
                }
            }
        }

        // --- RODAPÉ FIXO (BOTÕES) ---
        Rectangle {
            id: backStopTrue
            width:120
            height: 50
            radius: 10
            color: "white"
            border.width: 1
            visible: contadorParagens > 1
            anchors.right: nextStop.left
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Text {
                text: " < Anterior"
                font.pixelSize: 15
                font.bold: true
                color: "#9CA3AF"
                anchors.centerIn: parent
                font.capitalization: Font.AllUppercase
            }
            MouseArea {
                anchors.fill: parent
                onClicked: contadorParagens--
            }
        }

        // Versão desativada do botão anterior (para manter o layout)
        Rectangle {
            width:120
            height: 50
            radius: 10
            color: "white"
            border.width: 1
            opacity: 0.5
            visible: contadorParagens === 1
            anchors.right: nextStop.left
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Text {
                text: " < Anterior"
                font.pixelSize: 15
                color: "#9CA3AF"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: nextStop
            width:120
            height: 50
            radius: 10
            color: contadorParagens === valorEstaticoStop ? "#D4AF37" : "black"
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Text {
                text: contadorParagens != valorEstaticoStop ? "Próximo  >" : "TERMINAR"
                font.pixelSize: 15
                font.bold: true
                color: "white"
                anchors.centerIn: parent
                font.capitalization: Font.AllUppercase
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(contadorParagens < valorEstaticoStop) {
                        contadorParagens++
                    } else {
                        back()
                        recTours.visible = true
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
