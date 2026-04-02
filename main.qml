import QtQuick 2.15
import QtQuick.Controls 2.15
import "ApiHandler.js" as AH

Window {
    id: root
    visible: true
    width: 400
    height: 600
    title: "Strapi Demo"

    property var languages: ["Português", "Ingles", "Espanhol", "França"]
    property var marcadoresLinguas: ["pt", "en", "es" , "fr"]
    property string linguaEscolhida: ""

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
                    font.family: "Times New Roman"
                    font.weight: Font.Light
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
                    font.family: "Arial"
                    font.letterSpacing: 4.8
                    font.capitalization: Font.AllUppercase
                    color: "#6b7280"

                }
            }
        }

        Item {
            width: 1
            height: 40   //So serve para dar uma margem maior
        }

        Repeater {
            model: 4
            delegate: Column {
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: root.width / 2
                    height: 50
                    color: "WHITE"
                    border.color: mouseHandler.containsMouse ? "#D4AF37" : "lightgrey"
                    border.width: 1

                    // Adicionamos suavidade na transição das cores
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Text {
                        id: txtlanguages
                        text: languages[index]
                        font.pixelSize: 10
                        anchors.centerIn: parent
                        color: mouseHandler.containsMouse ? "#D4AF37" : "black"

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    MouseArea {
                        id: mouseHandler
                        anchors.fill: parent
                        hoverEnabled: true // OBRIGATÓRIO para detetar o rato sem clicar
                        cursorShape: Qt.PointingHandCursor // Muda o rato para a "mãozinha"

                        onClicked: {
                            linguaEscolhida = marcadoresLinguas[index]

                            AH.getData(linguaEscolhida, function(dados) {

                                strapiModel_Entity.clear()

                                for (var i = 0; i < dados.length; i++) {
                                    strapiModel_Entity.append({
                                        "nameEntity": dados[i].nameEntity
                                    })
                                }
                            })

                            nextPage = 1
                            col.visible = false
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
        sourceComponent: {
            if (nextPage === 1 ) return itemsPagina
        }
    }
    Component { id: itemsPagina; Items { onBack: nextPage = 0 } }
}

/*
LAYOUTS URL

BASE44 - https://app.base44.com/apps/69ca837f5eab68a88637b7c0/editor/preview
LAVOBLE - https://lovable.dev/projects/fd5f0ce2-b84f-4971-a993-3a65b0c5aac6
figma ta no pc

*/

/*
Melhor forma de organizar o projeto

xml http  request
Quantas chamadas preciso?

-Listar todas as areas
    Em todas as linguas do sistema (
    PT: http://127.0.0.1:1337/api/areas?locale=pt
    En: http://127.0.0.1:1337/api/areas?locale=en
)

-Listar todos os items dentro de uma area (
    -Em todas as linguas do sistema
        PT: http://127.0.0.1:1337/api/items?filters[area][documentId][$eq]=d7lcz79bahhizx4v32dl0d7h&filters[locale][$eq]=pt&populate=*
        En: http://127.0.0.1:1337/api/items?filters[area][documentId][$eq]=d7lcz79bahhizx4v32dl0d7h&filters[locale][$eq]=en&populate=*
)

(
NAO SEI SE VAI FUNCIONAR MAS FICA A IDEIA

http://127.0.0.1:1337/api/entidades?locale="+ lingua +"&populate[maps][populate][areas][populate][items][populate]=*

URL responsavel por retornar, Mapa - Area e items das areas. O recomendado seria dois
url,  um para map - areas e outro para area - items.
)


FLUXO DA APP TECNICO

Abre app --> Seleciona Lingua --> Verifica qual lingua foi selecionada ------------------------------> |
                                                                                                       |
Muda todas as urls do sistema para a lingua escolhida --> mostra todo o conteudo na lingua escolhida <--

Possiveis problemas

-Chamar areas ou items muda os dados e a forma como vou recebe los no qml
Exemplo em items temos os seguintes campos:
Item:

name text
description long text
cover media(image)
audio media(audio)
media media (image, video)
posX decimal
posY decimal

Area:

name text
subtitle text
description long text
image media (image)
audio media (audio)

Como podes ver temos alguns campos diferentes e
tudo ocncentrado no main.cpp penso que pode funcionar bem
pelp simples motivo de que são apenas duas colecoes e Com so alguns
campos que sao diferentes.

Qual a melhor forma de abordarmos isto pensando em todos estes erros?


http://127.0.0.1:1337/api/maps/chw6aohrfz4icaye740ftjnu?locale=pt&populate=areas
http://127.0.0.1:1337/api/maps/chw6aohrfz4icaye740ftjnu?locale=pt&populate[areas][populate][items]=*
*/
