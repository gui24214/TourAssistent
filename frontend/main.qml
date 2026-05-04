import QtQuick 2.15
import QtQuick.Controls 2.15
import "ApiHandler.js" as AH

Window {
    id: root
    visible: true
    width: 400
    height: 600
    title: "Strapi Demo"

    property var languages: ["Português", "English", "Español", "Français"]
    property var marcadoresLinguas: ["pt", "en", "es" , "fr"]
    property string linguaEscolhida: "pt"

    property int nextPage: 0

    Component.onCompleted: {
        AH.getData(linguaEscolhida, function(dados) {
            strapiModel_Entity.clear()

            for (var i = 0; i < dados.length; i++) {
                strapiModel_Entity.append({
                                              "nameEntity": dados[i].nameEntity
                                          })
            }
        })
    }

    ListModel {
        id: strapiModel_Entity
    }


    Column {
        id: col
        spacing: 10
        visible: true
        anchors.centerIn: parent


        Rectangle {
            id: recimgIconMuseum
            width: 60
            height: 60
            border.width: 0.5
            border.color: "#E8E8E8"
            anchors.horizontalCenter: parent.horizontalCenter
            radius : 50

            Image {
                width: 80
                height: 50
                source: "qrc:/images/images/IconMuseum.png"
                anchors.centerIn: parent
            }
        }

        Repeater {
            id: repeater
            model: strapiModel_Entity
            delegate:
                Column {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: txtMuseu
                    text: "MUSEU"
                    font.pixelSize: 36
                    font.family: playfairSemiBold.name
                    font.weight: Font.DemiBold
                    font.letterSpacing: 7.2
                    font.capitalization: Font.AllUppercase
                    color: "#000000"
                    renderType: Text.NativeRendering
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    id: txtEntity
                    text: model.nameEntity
                    font.pixelSize: 8
                    font.family: interRegular.name
                    font.letterSpacing: 4.8
                    font.capitalization: Font.AllUppercase
                    color: "#6b7280"
                }
            }
        }

        Item {
            width: 1
            height: 0   //So serve para dar uma margem maior
        }

        Rectangle {
            width: recimgIconMuseum.width
            height: 2
            color: "#D4AF37"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: 5
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: txtSelectLanguange
                text: "Selecione o idioma"
                font.pixelSize: 10
                font.family: interMedium.name
                font.letterSpacing: 4.8
                font.capitalization: Font.AllUppercase
                color: "#6b7280"
            }
        }

        Item {
            width: 1
            height: 20   //So serve para dar uma margem maior
        }

        Repeater {
            model: 4
            delegate: Column {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: root.width - 80
                    height: 60
                    color: "WHITE"
                    radius: 10
                    border.color: mouseHandler.containsMouse ? "#D4AF37" : "#E8E8E8"
                    border.width: 1

                    // Adicionamos suavidade na transição das cores
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        spacing: 20

                        Text {
                            id: txtlanguagesMarcars
                            text: marcadoresLinguas[index]
                            font.pixelSize: 15
                            font.family: interMedium.name
                            font.capitalization: Font.AllUppercase
                            color: mouseHandler.containsMouse ? "#D4AF37" : "#6b7280"

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        Text {
                            id: txtlanguages
                            text: languages[index]
                            font.pixelSize: 15
                            font.family: interMedium.name
                            color: mouseHandler.containsMouse ? "#D4AF37" : "#6b7280"

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }
                    }

                    MouseArea {
                        id: mouseHandler
                        anchors.fill: parent
                        hoverEnabled: true // OBRIGATÓRIO para detetar o rato sem clicar
                        cursorShape: Qt.PointingHandCursor // Muda o rato para a "mãozinha"

                        onClicked: {
                            linguaEscolhida = marcadoresLinguas[index]
                            nextPage = 1
                            col.visible = false

                            AH.getData(linguaEscolhida, function(dados) {
                                strapiModel_Entity.clear()

                                for (var i = 0; i < dados.length; i++) {
                                    strapiModel_Entity.append({
                                                                  "nameEntity": dados[i].nameEntity
                                                              })
                                }
                            })
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        active: nextPage !== 0
        opacity: active ? 1 : 0 // Se estiver ativo, opacidade 1, senão 0

        // Define a animação suave para a opacidade
        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
        sourceComponent: {
            if (nextPage === 1 ) return welcomePage
        }
    }

    Component { id: welcomePage; WelcomePage {
            linguaEscolhidaWelcome: linguaEscolhida
            onBack: nextPage = 0
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
}
