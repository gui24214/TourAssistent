import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import QtMultimedia
import "ApiHandler.js" as AH

Item {
    id: header
    width: 400
    height: 600

    signal back()

    ListModel { id: strapiModelHomePageTour }

    property string linguaSelecionada: ""
    property int indexTours: 0
    property int nextPageTours: 0
    property var selectedTourData: null

    property var dadosBrutos: null
    property string localMediaPath: ""

    property var tourItems: []

    Component.onCompleted: {
        AH.getData(linguaSelecionada, function(dados) {
            dadosBrutos = dados

            var mediaRaw = AH.extractMediaUrls(dados)
            var media = []
            var seen = {}

            for (var i = 0; i < mediaRaw.length; i++) {
                if (!seen[mediaRaw[i]]) {
                    seen[mediaRaw[i]] = true
                    media.push(mediaRaw[i])
                }
            }

            FileHelper.downloadFiles(media, AH.baseUrl, linguaSelecionada)
            localMediaPath = FileHelper.getLocalMediaFolder(linguaSelecionada)

            var tours = AH.getTours(dados, localMediaPath)

            strapiModelHomePageTour.clear()
            for (var k = 0; k < tours.length; k++) {
                strapiModelHomePageTour.append(tours[k])
            }

            indexTours = strapiModelHomePageTour.count
        })
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: "#E5E7EB"
    }

    ColumnLayout {
        id: contentColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 20
            leftMargin: 20
            rightMargin: 20
        }

        RowLayout {
            spacing: 8

            Item {
                width: 150
                height: 32

                Canvas {
                    implicitWidth: 25
                    implicitHeight: 26
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.strokeStyle = "#9CA3AF"
                        ctx.lineWidth = 2
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"

                        ctx.beginPath()
                        ctx.moveTo(8, 13); ctx.lineTo(3, 8); ctx.lineTo(8, 3)
                        ctx.moveTo(13, 8); ctx.lineTo(3, 8)
                        ctx.stroke()
                    }
                }

                Text {
                    text: "VOLTAR"
                    font.family: "Sans-Serif"
                    font.pixelSize: 15
                    font.letterSpacing: 1.5
                    font.capitalization: Font.AllUppercase
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    color: "#9CA3AF"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        back()
                        columnPrincipal.visible = true
                        alterarLingua.visible = true
                        imgEntity.visible = true
                    }
                }
            }
        }

        Text {
            text: "Visitas Guiadas"
            font.family: "Serif"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: "#111827"
            Layout.fillWidth: true
        }

        Text {
            text: indexTours + " percursos disponíveis"
            font.family: "Sans-Serif"
            font.pixelSize: 12
            color: "#9CA3AF"
            Layout.topMargin: 4
            Layout.fillWidth: true
        }
    }

    Rectangle {
        id: line
        width: parent.width
        height: 1
        color: "#9CA3AF"
        anchors.top: contentColumn.bottom
        anchors.topMargin: 20
    }

    Rectangle {
        id: recTours
        width: parent.width
        anchors {
            top: line.bottom
            bottom: parent.bottom
        }

        Rectangle {
            id: recRecurso
            width: parent.width - 40
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            ListView {
                id: listviewTour
                anchors.fill: parent
                anchors.topMargin: 20
                spacing: 15
                clip: true
                model: strapiModelHomePageTour

                delegate: Rectangle {
                    id: delegateRoot
                    width: recRecurso.width
                    height: layoutColuna.implicitHeight + 20
                    radius: 20
                    border.width: 1
                    border.color: mouseHandlerTour.containsMouse ? "#D4AF37" : "lightgrey"
                    color: "white"

                    Column {
                        id: layoutColuna
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 15
                        }
                        spacing: 10

                        Image {
                            id: imgComponent
                            source: model.imageTour
                            width: parent.width
                            height: 120
                            fillMode: Image.PreserveAspectCrop
                            clip: true
                        }

                        Text {
                            text: model.nameTour
                            font.pixelSize: 18
                            font.bold: true
                            color: "#111827"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Row {
                            spacing: 30

                            Row {
                                spacing:10

                                Image {
                                    source: "qrc:/images/images/clockGold.png"
                                    width: 25
                                    height: 25
                                }

                                Text {
                                    text: model.timeTour
                                    font.pixelSize: 12
                                    color: "#D4AF37"
                                    anchors.top: parent.top
                                    anchors.topMargin: 5
                                }
                            }

                            Text {
                                text: "."
                                font.pixelSize: 18
                                color: "#4B5563"
                            }

                            Text {
                                text: model.totalStops + " Paragens"
                                font.pixelSize: 12
                                color: "#4B5563"
                                anchors.top: parent.top
                                anchors.topMargin: 5
                            }
                        }

                        Text {
                            text: model.descriptionTour
                            font.pixelSize: 13
                            color: "#4B5563"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }

                    MouseArea {
                        id: mouseHandlerTour
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            selectedTourData = model

                            tourItems = AH.getTourItems(
                                        dadosBrutos,
                                        model.documentId,
                                        localMediaPath
                                        )

                            nextPageTours = 1
                            recTours.visible = false
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: gameLoader
        anchors.fill: parent
        active: nextPageTours !== 0
        opacity: active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 500 }
        }

        sourceComponent: (nextPageTours === 1) ? tourPage : undefined
    }

    Component {
        id: tourPage

        TourPage {
            linguaSelecionadaTourPage: linguaSelecionada
            onBack: nextPageTours = 0

            tourInfo: selectedTourData
            tourInfoMap: selectedTourData && dadosBrutos
                         ? AH.getTourMaps(dadosBrutos, selectedTourData.documentId, localMediaPath)
                         : []


            tourInfoItem: tourItems
        }
    }
}
