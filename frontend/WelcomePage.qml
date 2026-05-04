import QtQuick 2.15
import QtQuick.Controls 2.15
import "ApiHandler.js" as AH

Item {
    id: welcomeItem
    width: 400
    height: 600

    signal back()
    property var lingua: []
    property int nextPageWelcome: 0
    property string linguaEscolhidaWelcome: ""



    Component.onCompleted: {
        AH.getData(linguaEscolhidaWelcome, function(dados) {

            var mediaRaw = AH.extractMediaUrls(dados)

            var media = []
            var seen = {}

            for (var i = 0; i < mediaRaw.length; i++) {
                if (!seen[mediaRaw[i]]) {
                    seen[mediaRaw[i]] = true
                    media.push(mediaRaw[i])
                }
            }

            // 1. faz download das imagens
            FileHelper.downloadFiles(media, AH.baseUrl, linguaEscolhidaWelcome)

            // 2. pega caminho local
            var localMediaPath = FileHelper.getLocalMediaFolder(linguaEscolhidaWelcome)

            // 3. agora sim constrói entidades com local path
            var entidades = AH.getEntities(dados, localMediaPath)

            strapiModelWelcomePage.clear()

            for (var i = 0; i < entidades.length; i++) {
                strapiModelWelcomePage.append({
                                                  "descriptionEntity": entidades[i].descriptionEntity,
                                                  "imageEntityUrl": entidades[i].imageEntityUrl
                                              })
            }
        })
    }

    ListModel {
        id: strapiModelWelcomePage
    }


    Item {
        id: imgEntity
        width: welcomeItem.width
        height: 300
        // Usa a propriedade de estado em vez do Loader diretamente
        visible: nextPageWelcome === 0
        enabled: visible // Garante que não consome recursos se não estiver visível

        Image {
            anchors.fill: parent
            // Evita carregar a imagem se o scanner estiver aberto para poupar RAM
            source: (nextPageWelcome === 0 && strapiModelWelcomePage.count > 0)
                    ? strapiModelWelcomePage.get(0).imageEntityUrl
                    : ""
            fillMode: Image.PreserveAspectCrop

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.6; color: "#CCFFFFFF" }
                        GradientStop { position: 1.0; color: "white" }
                    }
                }
            }
        }

    Rectangle {
        id: alterarLingua
        width: 50
        height: 50
        radius: 150
        border.width: 2
        border.color: "#D4AF37"
        color: "transparent"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20

        Text {
            id: txtLanguage
            text: linguaEscolhidaWelcome
            font.family: interSemiBold.name
            font.pixelSize: 14
            font.capitalization: Font.AllUppercase
            color: "#D4AF37"
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                back()
                col.visible = true
            }
        }
    }

    Column {
            id: columnPrincipal
            width: parent.width * 0.9
            anchors.horizontalCenter: parent.horizontalCenter
            y: 150 // Usa y em vez de anchors.top se o topo estiver a variar
            spacing: 15

        Text {
            text: "Bem Vindo"
            font.family: playfairSemiBold.name
            font.pixelSize: 30
            font.weight: Font.DemiBold
            font.letterSpacing: 2
            color: "#1a1a1a"
            anchors.horizontalCenter: parent.horizontalCenter
            bottomPadding: 16 // Aproximação de 4 unidades Tailwind (4 * 4px)
        }

        Repeater {
            model: strapiModelWelcomePage
            delegate:

                Text {
                text: model.descriptionEntity
                width: parent.width
                font.family: interRegular.name
                font.pixelSize: 14
                lineHeight: 1.6
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: "#6b7280"
            }
        }
    }

    Rectangle {
        id: recInfo
        width: parent.width - 40
        height: 80
        color: "#f7f7f7"
        border.width: 1
        radius: 10
        border.color: "#D3D3D3"
        anchors.top: columnPrincipal.bottom
        anchors.topMargin:50
        anchors.horizontalCenter: parent.horizontalCenter


        Rectangle {
            id: informacoes2
            width: 18
            height: 18
            radius: 150
            border.width: 2
            border.color: "#D4AF37"
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 20

            Text {
                id: i
                text: "i"
                font.bold: true
                color: "#D4AF37"
                font.pixelSize: 10
                anchors.centerIn: parent
            }
        }

        Column {
            anchors.left: informacoes2.right
            anchors.leftMargin: 5
            anchors.top: parent.top
            anchors.topMargin: 10
            spacing: 5

            Text {
                text: "Informações da visita"
                font.pixelSize: 13
                font.family: interSemiBold.name
                color: "black"
            }

            Text {
                text: "Horário: 10h – 18h · Duração média: 90 min"
                font.pixelSize: 13
                font.family: interRegular.name
                color: "#6b7280"
            }

            Text {
                text: "Wi-Fi gratuito disponível em todo o museu"
                font.pixelSize: 13
                font.family: interRegular.name
                color: "#6b7280"
            }
        }
    }


    Column {
        id: colbuttons
        anchors.top: recInfo.bottom
        anchors.topMargin: 0
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10

        Rectangle {
            id: recIniciarVisita
            width: welcomeItem.width - 40
            height: 60
            radius: 10
            color:"black"

            Behavior on border.color { ColorAnimation { duration: 200 } }

            Item {
                id: contentRowInciarVsita
                anchors.centerIn: parent
                height: childrenRect.height
                width: childrenRect.width

                Row {
                    spacing: 20
                    anchors.centerIn: parent

                    Image {
                        id: mapIcon
                        source: "qrc:/images/images/icons8-map-24.png"
                    }

                    Text {
                        text: "Iniciar Visita"
                        font.family: interRegular.name
                        font.pixelSize: 15
                        font.letterSpacing: 2
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                        color: "WHITE"
                        anchors.verticalCenter: mapIcon.verticalCenter
                    }
                }
            }

            MouseArea {
                id: mouseHandlerWelcomePage2
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    nextPageWelcome = 1
                    columnPrincipal.visible = false
                    alterarLingua.visible = false
                    imgEntity.visible = false
                }
            }
        }

        Rectangle {
            width: welcomeItem.width - 40
            height: 50
            color: "WHITE"
            radius: 10
            border.width: 1
            border.color:"#D4AF37"

            // Adicionamos suavidade na transição das cores
            Behavior on border.color { ColorAnimation { duration: 200 } }


            Item {
                id: contentRow
                anchors.centerIn: parent
                height: childrenRect.height
                width: childrenRect.width

                Row {
                    spacing: 20
                    anchors.centerIn: parent

                    Image {
                        id: headsetIcon
                        source: "qrc:/images/images/headphone.png"
                    }

                    Text {
                        id: txtVisitaGuiada
                        text: "Visitas Guiadas"
                        font.family: interRegular.name
                        font.pixelSize: 15
                        font.letterSpacing: 1.4
                        font.capitalization: Font.AllUppercase
                        color: "#D4AF37"
                    }
                }
            }

            MouseArea {
                id: mouseHandlerWelcomePage
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    nextPageWelcome = 2 // Define o ID para a página de tours
                    columnPrincipal.visible = false
                    alterarLingua.visible = false
                    imgEntity.visible = false
                }
            }
        }
    }

    Text {
        text: "Áudio-guia incluído · Disponível em 4 idiomas"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: colbuttons.bottom
        anchors.topMargin: 10
        font.family: interRegular.name
        font.pixelSize: 11
        color: "#9ca3af"
        horizontalAlignment: Text.AlignHCenter
    }

    GlobalQrButton {
        id: qrButton
        x: (welcomeItem.width - qrButton.width) - 20
        y: 20
        visible: true

        MouseArea {
            anchors.fill: parent
            drag.target: parent
            drag.axis: Drag.XAndYAxis

            onPositionChanged: {
                // limite horizontal
                if (parent.x < 0)
                    parent.x = 0
                if (parent.x + parent.width > welcomeItem.width)
                    parent.x = welcomeItem.width - parent.width

                // limite vertical
                if (parent.y < 0)
                    parent.y = 0
                if (parent.y + parent.height > welcomeItem.height)
                    parent.y = welcomeItem.height - parent.height
            }

            onClicked: {
                nextPageWelcome = 3
                qrButton.visible = false
                colbuttons.visible = false
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        active: nextPageWelcome !== 0
        opacity: active ? 1 : 0 // Se estiver ativo, opacidade 1, senão 0

        // Define a animação suave para a opacidade
        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
        sourceComponent: {
            if (nextPageWelcome === 1 ) return homepage
            if (nextPageWelcome === 2) return toursPage
            if (nextPageWelcome === 3) return qrScannerPage
        }
    }

    Component {
        id: homepage;
        HomePage {
            linguaEscolhidaHome: linguaEscolhidaWelcome
            onBack: nextPageWelcome = 0
        }
    }

    Component {
        id: toursPage
        Tours { // Nome do ficheiro do seu segundo código
            onBack: nextPageWelcome = 0
            linguaSelecionada : linguaEscolhidaWelcome
        }
    }

    Component {
            id: qrScannerPage
            ScannerPage {
                onBack: nextPageWelcome = 0
                linguaSelecionadaQrCode : linguaEscolhidaWelcome
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
