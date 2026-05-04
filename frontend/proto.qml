import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
    id: header
    width: 400
    height: 600

    property var numbers: [0,1,2,3,4,5,6,7,8,9]
    property int numberSelected: 0

    property string operations: ["*","+","-","/"]
    property string operationSelected: ""

    Rectangle {
        id: recTotal
        anchors.fill: parent
        color: "white"


        Grid {
            id: grid
            rows: 2
            columns: 5
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: 10
                delegate: Rectangle {
                    id: recNumbers
                    width: 30
                    height: 30
                    radius: 50
                    border.width: 1

                    Text{
                        id: txtNumbers
                        text: numbers[index]
                        anchors.centerIn: parent
                        font.pixelSize: 13
                        color: "black"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            numberSelected = numbers[index]
                            txtNumbers1_false.visible = true
                            txtNumbers1.visible = false
                        }
                    }
                }
            }
        }

        Row {
            anchors.top: grid.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Repeater {
                model: 4
                delegate: Rectangle {
                    id: recOperations
                    width: 30
                    height: 30
                    color: "yellow"
                    radius: 50
                    border.width: 1

                    Text{
                        id: txtOperations
                        text: operations[index]
                        anchors.centerIn: parent
                        font.pixelSize: 13
                        color: "black"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            operationSelected = operations[index]
                            txtoperation1_false.visible = true
                            txtoperation1.visible = false
                        }
                    }
                }
            }
        }

        Text {
            id: txtNumbers1
            anchors.centerIn: parent
            text: numberSelected
            visible: true
        }


        Text {
            id: txtNumbers1_false
            anchors.centerIn: parent
            text: txtNumbers1.text
            visible: false
            color: "red"
        }

        Text {
            id: txtoperation1
            anchors.left: txtNumbers1.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: operationSelected
            visible: true
        }


        Text {
            id: txtoperation1_false
            anchors.left: txtNumbers1.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: txtoperation1.text
            visible: false
            color: "red"
        }
    }
}




/*
=====================ORDEM BRANCH
Do ultimo para o mais recente

-...
-PageTour_Final
-PageTour
-tour
-Melhora_No_Feedback_HomePage
-main

http://127.0.0.1:1337/api/entidades?locale=pt
&populate[imageEntity]=true&populate[audio]=true
&populate[tours][populate][imageTour]=true
&populate[tours][populate][maps]=true
&populate[tours][populate][items][populate][coverItem]=true
&populate[maps][populate][imageMap]=true
&populate[maps][populate][areas][populate][imageArea]=true
&populate[maps][populate][areas][populate][items][populate][coverItem]=true

A FAZER!!

-QrCODE Image Strapi
-git push do backend e frontend
-Alterar dados locais com os campos da colection Dictionary
-Relatorio

===========================================Dictionary =================================================


main

-mainName: MUSEU
-mainSelectLanguange: SELECIONE O IDIOMA
-mainMarkersLanguange: pt/en/es/fr
-mainLanguanges: Português, English, Español, Français

WelcomePage

-welcomeText: Bem Vindo
-welcomeInfoVisitTitle: Informações da visita
-welcomeInfoTime: Horário: 10h - 18h
-welcomeAverageDuration: Duração média: 90 min
-welcomeButtonstartvisit: Iniciar visita
-welcomeButtonsGuiedTour: Visitas guiadas
-welcomeAvailableLanguages: Áudio-guia incluido . Disponível em 4 idiomas

Tours

-toursButtonBack: Voltar
-toursGuiedTour: Visitas Guiadas
-toursAvailableTours: percursos disponíveis

TourPage

-tourPageAudioGuide: AUDIO-GUIA
-tourPageButtonBack: Anterior
-tourPageButtonNext: Próximo
-tourPageButtonEnd: Terminar

ScannerPage:

-scannerPageSmartAcces: QR Smart Access
-scannerPageScanQrCode: Scan QR Code
-scannerPageDescription: Aponte para uma obra ou espaço do museu
-scannerPageDetectQrCode: A detectar QR code...
-scannerPagerecognized: QR Reconhecido
-scannerPageLoadContent: A carregar conteúdo...
-scannerPageSeeMap: Ver no Mapa

*/

