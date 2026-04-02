import QtQuick 2.15
import QtQuick.Controls 2.15
import "ApiHandler.js" as AH

Item {
    id: rootItem
    width: 400
    height: 600

    signal back()

    ListModel {
        id: strapiModel
    }

    // function carregarDadosMap() {
    //     var xhr = new XMLHttpRequest();
    //     var url = "http://127.0.0.1:1337/api/items?locale="+ linguaEscolhida +"&populate=*"
    //    // console.log("URL:", url)

    //     xhr.open("GET", url);

    //     xhr.onreadystatechange = function() {
    //         if (xhr.readyState === XMLHttpRequest.DONE) {
    //             if (xhr.status === 200) {
    //                 var jsonResponse = JSON.parse(xhr.responseText);
    //                 var dados = jsonResponse.data;

    //                 strapiModel.clear();

    //                 for (var i = 0; i < dados.length; i++) {
    //                     var item = dados[i];

    //                     var relativeUrl = "";
    //                     if (item.coverItem && item.coverItem.url) {
    //                         relativeUrl = item.coverItem.url;
    //                     }

    //                     strapiModel.append({
    //                         "nameItem": item.nameItem || "",
    //                         "descriptionItem": item.descriptionItem || "",
    //                         "posXItem": item.posXItem || 0.0,
    //                         "posYItem": item.posYItem || 0.0,
    //                         "coverUrlItem": relativeUrl !== "" ? "http://127.0.0.1:1337" + relativeUrl : ""
    //                     });
    //                 }

    //                 //console.log("Itens carregados:", strapiModel.count);
    //                 //console.log(""+ url)
    //             } else {
    //                 //console.error("Erro API:", xhr.status);
    //             }
    //         }
    //     };
    //     xhr.send();
    // }

    Component.onCompleted: {
        AH.getData(linguaEscolhida, function(dados) {

            var items = AH.getItems(dados)
            strapiModel.clear()

            for (var i = 0; i < items.length; i++) {
                strapiModel.append({
                                              "nameItem": items[i].nameItem,
                                              "coverUrlItem": items[i].coverUrlItem,
                                              "descriptionItem": items[i].descriptionItem,
                                              "posXItem": items[i].posXItem,
                                              "posYItem": items[i].posYItem
                                          })
            }
        })
    }


    Rectangle {
        width: 150
        height: 60
        radius: 10
        color: "black"

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20

        Text {
            text: "BACK"
            font.pixelSize: 18
            anchors.centerIn: parent
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked:  {
                back()
                col.visible = true
            }
        }
    }


    ListView {
        id: view
        anchors {
            top: parent.top
            topMargin: 100
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        model: strapiModel
        spacing: 10
        clip: true

        delegate: Rectangle {
            width: view.width
            height: 140
            color: "#f8f8f8"
            border.color: "#ddd"
            radius: 8

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 15

                Image {
                    width: 100
                    height: 100
                    source: model.coverUrlItem
                    fillMode: Image.PreserveAspectCrop

                    Rectangle {
                        anchors.fill: parent
                        color: "#eee"
                        z: -1
                    }
                }

                Column {
                    width: parent.width - 125
                    spacing: 5
                    clip: true

                    Text {
                        text: model.nameItem
                        font.bold: true
                        font.pixelSize: 16
                        elide: Text.ElideRight
                    }

                    Text {
                        text: model.descriptionItem
                        font.pixelSize: 12
                        color: "#666"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "X: " + model.posXItem.toFixed(2) + " | Y: " + model.posYItem.toFixed(2)
                        font.pixelSize: 10
                        color: "blue"
                    }
                }
            }
        }
    }
}
