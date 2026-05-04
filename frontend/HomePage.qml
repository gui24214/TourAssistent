import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia
import "ApiHandler.js" as AH

Item {
    id: homePageItem
    width:360
    height: 620


    Timer {
        id: timerPositionMap
        interval: 16
        running: false
        repeat: false

        onTriggered: {
            var pinX = mapScale.origin.x
            var pinY = mapScale.origin.y

            var meioX = imageMap.paintedWidth / 2
            var meioY = imageMap.paintedHeight / 2

            var mapW = imageMap.paintedWidth
            var mapH = imageMap.paintedHeight

            var offsetSmall = 0
            var offsetMedium = 0.50
            var offsetLarge = 0.45

            // Limpeza de âncoras para evitar conflitos
            itemInfoArea.anchors.left = undefined
            itemInfoArea.anchors.right = undefined
            itemInfoArea.anchors.top = undefined
            itemInfoArea.anchors.bottom = undefined

            itemInfoItem.anchors.left = undefined
            itemInfoItem.anchors.right = undefined
            itemInfoItem.anchors.top = undefined
            itemInfoItem.anchors.bottom = undefined

            // MOBILE
            if (homePageItem.width < 500) {
                var offsetX = mapW * offsetSmall
                var offsetY = mapH * offsetSmall

                if (pinY < meioY) {
                    mapTranslate.x = offsetX
                    mapTranslate.y = offsetY
                    itemInfoArea.anchors.bottom = homePageItem.bottom
                    itemInfoItem.anchors.bottom = homePageItem.bottom
                } else {
                    mapTranslate.x = offsetX
                    mapTranslate.y = -offsetY
                    itemInfoArea.anchors.top = homePageItem.top
                    itemInfoItem.anchors.top = homePageItem.top
                }
                // No mobile, ancora à direita do item principal
                itemInfoArea.anchors.right = homePageItem.right
                itemInfoItem.anchors.right = homePageItem.right
            }

            // TABLET
            else if (homePageItem.width < 800) {
                var scaledW = mapW * mapScale.xScale
                var scaledH = mapH * mapScale.yScale
                var desiredX = (mapW / 2) - pinX
                var desiredY = (mapH / 2) - pinY
                var maxTranslateX = (scaledW - mapW) / 2
                var maxTranslateY = (scaledH - mapH) / 2

                function clamp(v, min, max) {
                    return Math.max(min, Math.min(max, v))
                }

                var offsetXTab = mapW * 0.25
                var offsetYTab = mapH * offsetMedium // Usando a variável de offset correta

                mapTranslate.x = clamp(desiredX - offsetXTab, -maxTranslateX, maxTranslateX)
                mapTranslate.y = clamp(desiredY, -maxTranslateY, maxTranslateY)

                if (pinY < meioY) {
                    itemInfoArea.anchors.bottom = homePageItem.bottom
                    itemInfoItem.anchors.bottom = homePageItem.bottom
                } else {
                    itemInfoArea.anchors.top = homePageItem.top
                    itemInfoItem.anchors.top = homePageItem.top
                }
                itemInfoArea.anchors.right = homePageItem.right
                itemInfoItem.anchors.right = homePageItem.right
            }

            // DESKTOP
            else {
                var scaledW2 = mapW * mapScale.xScale
                var scaledH2 = mapH * mapScale.yScale
                var desiredX2 = (mapW / 2) - pinX
                var desiredY2 = (mapH / 2) - pinY
                var maxTranslateX2 = (scaledW2 - mapW) / 2
                var maxTranslateY2 = (scaledH2 - mapH) / 2

                function clamp2(v, min, max) {
                    return Math.max(min, Math.min(max, v))
                }

                var offsetXDesk = mapW * 0.20
                var offsetYDesk = mapH * offsetLarge // Definindo o offsetY para o Desktop

                mapTranslate.x = clamp2(desiredX2 - offsetXDesk, -maxTranslateX2, maxTranslateX2)
                mapTranslate.y = clamp2(desiredY2, -maxTranslateY2, maxTranslateY2)

                if (pinY < meioY) {
                    // Se clicar na parte de cima, painel aparece em baixo
                    itemInfoArea.anchors.bottom = homePageItem.bottom
                    itemInfoItem.anchors.bottom = homePageItem.bottom
                } else {
                    // Se clicar na parte de baixo, painel aparece em cima
                    itemInfoArea.anchors.top = homePageItem.top
                    itemInfoItem.anchors.top = homePageItem.top
                }
                // Garante que ancora à direita do componente pai (homePageItem)
                itemInfoArea.anchors.right = homePageItem.right
                itemInfoItem.anchors.right = homePageItem.right

                // Adiciona uma margem para não ficar colado à borda no desktop
                itemInfoArea.anchors.rightMargin = 20
                itemInfoItem.anchors.rightMargin = 20
            }
        }
    }

    Timer {
        id: animationRecInformations
        interval: 300
        running: true
        repeat: false
        onTriggered: {
            itemInfoEntity.anchors.rightMargin = 10
        }
    }

    Timer {
        id: animationRecInformationsArea
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            itemInfoArea.anchors.rightMargin = 10
        }
    }

    Timer {
        id: animationRecInformationsItem
        interval: 300
        running: false
        repeat: false
        onTriggered: {
            itemInfoItem.anchors.rightMargin = 10
        }
    }


    Timer {
        id: scrollAutomate
        interval: 16
        running: false
        repeat: true
        onTriggered: {
            // Rola a entidade se estiver visível e tiver conteúdo maior que a altura
            if (listViewEntity.visible && listViewEntity.contentHeight > listViewEntity.height) {
                listViewEntity.contentY += valorTimerEntity
            }

            // Rola as áreas
            if (listViewAreas.visible && listViewAreas.contentHeight > listViewAreas.height) {
                listViewAreas.contentY += valorTimerArea
            }

            // Rola os itens
            if (listViewItems.visible && listViewItems.contentHeight > listViewItems.height) {
                listViewItems.contentY += valorTimerItem
            }
        }
    }

    signal back()

    property string linguaEscolhidaHome: ""
    property int currentFloor: 0

    property var colorpin: ["#FF3B30","#34C759","#FF9500","#E11D48","#A3E635","#FF2D55","#FACC15","#BE123C","#84CC16","#FB923C","#F43F5E","#FFD60A","#DC2626","#D9F99D","#F97316","#FF375F","#FDE047","#B91C1C","#65A30D","#EA580C"]
    property var areasPin: ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
    property var itemsPin: [1,2,3,4,5]

    property string corSelecionadaArea: ""
    property string areaSelcionada: ""

    property int selectedPinIndex: -1
    property int selectedPinIndexItem: -1
    property int selectedPinIndexEntity: 0

    property int recInformacoes: 250

    property double valorTimerEntity: 0.3
    property double valorTimerArea: 0.3
    property double valorTimerItem: 0.3

    property int valorAtualIndex: -1
    property string colorSelect: "#304993"

    function resetZoom() {
        selectedPinIndex = -1
        selectedPinIndexItem = -1

        mapScale.xScale = 1
        mapScale.yScale = 1
        mapTranslate.x = 0
        mapTranslate.y = 0

        recbackzoom.visible = false
        retanguloComentario.visible = true
        retanguloitems.visible = false
        itemInfoArea.visible = false
        recInformacoesItem.visible = false
        recback.visible = true
        recRow.visible = true

        itemInfoEntity.visible = true
        itemInfoArea.anchors.rightMargin = -220
        itemInfoItem.anchors.rightMargin = -220
        itemInfoItem.visible = false
        valorAtualIndex = -1
    }

    ListModel { id: strapiModelHomePageEntity }
    ListModel { id: strapiModelHomePage }
    ListModel { id: strapiModelHomePageAreas }
    ListModel { id: strapiModelHomePageItems }

    Component.onCompleted: {
        AH.getData(linguaEscolhidaHome, function(dados) {

            var mediaRaw = AH.extractMediaUrls(dados)
            var media = []
            var seen = {}
            for (var i = 0; i < mediaRaw.length; i++) {
                if (!seen[mediaRaw[i]]) {
                    seen[mediaRaw[i]] = true
                    media.push(mediaRaw[i])
                }
            }
            FileHelper.downloadFiles(media, AH.baseUrl, linguaEscolhidaHome)

            var localPath = FileHelper.getLocalMediaFolder(linguaEscolhidaHome)  // Vai buscar os media de forma offline
            // 3. CARREGAR OS DADOS USANDO O LOCALPATH
            var entidades = AH.getEntities(dados, localPath)
            var maps = AH.getMaps(dados, localPath)
            var areas = AH.getAreas(dados, localPath)
            var items = AH.getItems(dados, localPath)

            strapiModelHomePage.clear()
            strapiModelHomePageAreas.clear()
            strapiModelHomePageEntity.clear()
            strapiModelHomePageItems.clear()

            for (var k = 0; k < entidades.length; k++) {
                strapiModelHomePageEntity.append(entidades[k])

                if (strapiModelHomePageEntity.count > 0) {
                    var firstEntity = strapiModelHomePageEntity.get(0);
                    if (firstEntity.audio) {
                        player.source = firstEntity.audio;
                        player.play();
                    }
                }
            }

            for (var m = 0; m < maps.length; m++) {
                strapiModelHomePage.append(maps[m])
            }

            for (var j = 0; j < areas.length; j++) {
                strapiModelHomePageAreas.append(areas[j])
            }

            for (var l = 0; l < items.length; l++) {
                strapiModelHomePageItems.append(items[l])
            }
            scrollAutomate.running = true
        })
    }

    Rectangle {
        id: recback
        width: 30
        height: 30
        radius: 15
        border.width: 1
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        z: 10

        Text {
            text: "<"
            font.pixelSize: 20
            anchors.centerIn: parent
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

    Rectangle {
        id: recbackzoom
        width: 35
        height: 35
        radius: 15
        border.width: 1
        color: "white"
        visible: false
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 20
        z: 10

        Text {
            text: ">" + areaSelcionada
            font.pixelSize: 20
            color: "white"
            font.bold: true
            anchors.centerIn: parent
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                resetZoom()
            }
        }
    }

    Rectangle {
        id: recRow
        width: parent.width
        height: 60
        visible: true
        border.width: 0.5
        anchors.top: recback.bottom
        anchors.topMargin: 20

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            spacing: 10

            Repeater {
                model: strapiModelHomePage

                delegate: Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    Text {
                        text: model.floorMap ? model.floorMap : ""
                        font.pixelSize: 18
                        font.bold: currentFloor === index
                        color: currentFloor === index ? "#D4AF37" : "black"
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: currentFloor = index
                    }
                }
            }
        }
    }
    // MAPA
    Rectangle {
        id: recTotal
        anchors.top: recRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Item {
            id: mapContainer
            anchors.centerIn: parent
            width: parent.width * 0.9
            height: parent.height * 0.8

            transform: [
                Scale {
                    id: mapScale
                    origin.x: 0
                    origin.y: 0

                    Behavior on xScale {
                        NumberAnimation {
                            duration: 300;
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on yScale {
                        NumberAnimation {
                            duration: 300;
                            easing.type: Easing.InOutQuad
                        }
                    }
                },
                Translate {
                    id: mapTranslate
                }
            ]

            Image {
                id: imageMap
                width: parent.width
                height: parent.height
                fillMode: Image.PreserveAspectFit
                cache: true
                asynchronous: true
                source: (strapiModelHomePage.count > 0 && currentFloor < strapiModelHomePage.count)
                        ? strapiModelHomePage.get(currentFloor).imageMapUrl
                        : ""
                mipmap: true
                smooth: true
                antialiasing: true
            }

            Rectangle {
                id: retanguloComentario
                color: "transparent"
                visible: true
                width: imageMap.paintedWidth
                height: imageMap.paintedHeight
                anchors.centerIn: parent

                Repeater {
                    model: strapiModelHomePageAreas

                    delegate: Item {
                        visible: model.mapIndex === currentFloor
                        width: 30
                        height: 40

                        x: (model.posX * parent.width) - (width / 2)
                        y: (model.posY * parent.height) - (height / 2)

                        Rectangle {
                            width: 30
                            height: 30
                            radius: width / 2
                            color: colorpin[index]
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top

                            Rectangle {
                                width: 10
                                height: 10
                                color: colorpin[index]
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: -5
                                rotation: 45
                                z: -1
                            }

                            Text {
                                text: areasPin[index]
                                font.pixelSize: 18
                                color: "white"
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectedPinIndex = index
                                selectedPinIndexItem = index // Correção do nome aqui
                                corSelecionadaArea = colorpin[index]
                                areaSelcionada = areasPin[index]

                                // Visibilidade da interface, prevenção de erros e bugs
                                retanguloComentario.visible = false
                                recbackzoom.color = colorpin[index]
                                recbackzoom.visible = true
                                retanguloitems.visible = true
                                itemInfoArea.visible = true
                                itemInfoEntity.visible = false
                                recback.visible = false
                                recRow.visible = false

                                animationRecInformationsArea.running = true
                                scrollAutomate.running = true
                                itemInfoEntity.anchors.rightMargin = -220
                                itemInfoEntity.anchors.bottomMargin = -220
                                valorTimerEntity = 0

                                // Lógica de Zoom
                                // Pegamos a posição do PIN em relação ao tamanho da imagem pintada
                                var pinX = model.posX * imageMap.paintedWidth
                                var pinY = model.posY * imageMap.paintedHeight

                                // Centralizamos o ponto de origem do zoom no PIN
                                mapScale.origin.x = pinX
                                mapScale.origin.y = pinY

                                // Aplicamos o zoom
                                mapScale.xScale = 2.0
                                mapScale.yScale = 2.0

                                timerPositionMap.running = true

                                AH.getData(linguaEscolhidaHome, function(dados) {
                                    var localPath = FileHelper.getLocalMediaFolder(linguaEscolhidaHome)
                                    var items = AH.getItems(dados, localPath)
                                    strapiModelHomePageItems.clear()

                                    for (var i = 0; i < items.length; i++) AH.getData(linguaEscolhidaHome, function(dados) {
                                        var items = AH.getItems(dados, localPath)
                                        strapiModelHomePageItems.clear()

                                        for (var i = 0; i < items.length; i++) {

                                            if (items[i].areaIndex === index && items[i].mapIndex === currentFloor) {
                                                console.log("QR:", items[i].qrCode)
                                                strapiModelHomePageItems.append({
                                                                                    "posXItem": items[i].posXItem,
                                                                                    "posYItem": items[i].posYItem,
                                                                                    "nameItem": items[i].nameItem,
                                                                                    "coverUrlItem": items[i].coverUrlItem,
                                                                                    "descriptionItem": items[i].descriptionItem,
                                                                                    "areaIndex": items[i].areaIndex,
                                                                                    "qrCode": items[i].qrCode
                                                                                })
                                            }
                                        }
                                    })
                                })
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: retanguloitems
                color: "transparent"
                visible: false
                width: imageMap.paintedWidth
                height: imageMap.paintedHeight
                anchors.centerIn: parent

                Repeater {
                    model: strapiModelHomePageItems

                    delegate: Item {
                        visible: true
                        width: 20
                        height: 30

                        x: (model.posXItem * parent.width) - (width / 2)
                        y: (model.posYItem * parent.height) - (height / 2)

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            opacity: 0.5
                        }

                        Rectangle {
                            id: cimaPinItem
                            width: 20
                            height: 20
                            radius: width / 2
                            color: valorAtualIndex != index ? corSelecionadaArea : colorSelect
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top

                            Rectangle {
                                id: baixoPinItem
                                width: 10
                                height: 10
                                color: valorAtualIndex != index ? corSelecionadaArea : colorSelect
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottomMargin: -5
                                rotation: 45
                                z: -1
                            }

                            Text {
                                text: itemsPin[index]
                                font.pixelSize: 14
                                color: "white"
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                itemInfoArea.visible = false
                                recInformacoesItem.visible = true
                                selectedPinIndexItem = index
                                itemInfoItem.visible = true
                                animationRecInformationsItem.running = true
                                scrollAutomate.running = true
                                valorAtualIndex = index
                                listViewItems.positionViewAtBeginning()
                            }
                        }
                    }
                }
            }

            Item  {
                id: itemInfoEntity
                width: recInformacoes
                visible: true
                height: recInformacoesEntity.height
                anchors.right: parent.right
                anchors.rightMargin: -220
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                Behavior on anchors.rightMargin {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on anchors.bottomMargin {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }

                Rectangle {
                    id: recCloseInfo
                    width: 60
                    height: 40
                    radius: 20
                    border.width: 1
                    color: "white"
                    anchors.right: recInformacoesEntity.left
                    anchors.rightMargin: -20
                    anchors.top: recInformacoesEntity.top
                    anchors.topMargin: 50

                    Rectangle {
                        id: informacoes2
                        width: 18
                        height: 18
                        radius: 150
                        border.width: 2
                        border.color: "#D4AF37"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 25

                        Text {
                            id: i
                            text: "-"
                            font.bold: true
                            color: "#D4AF37"
                            font.pixelSize: 13
                            anchors.centerIn: parent
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(itemInfoEntity.anchors.rightMargin > 0) {
                                itemInfoEntity.anchors.rightMargin = -220
                                itemInfoEntity.anchors.bottomMargin = -220
                                scrollAutomate.stop()
                                i.text = "i"
                            } else {
                                itemInfoEntity.anchors.rightMargin = 10
                                itemInfoEntity.anchors.bottomMargin = 10
                                scrollAutomate.running = true
                                i.text = "-"
                            }
                            animationRecInformations.running = false
                            valorTimerEntity = 0.3
                            listViewEntity.positionViewAtBeginning()  //Serve para o conteudo ser mostrado sempre encima
                        }
                    }
                }

                Rectangle {
                    id: recInformacoesEntity
                    width: recInformacoes
                    height: homePageItem.height / 2
                    border.width: 1
                    visible:true
                    radius: 40

                    ListView {
                        id: listViewEntity
                        anchors.fill: parent
                        anchors.margins: 20
                        model: strapiModelHomePageEntity.count > 0 ? 1 : 0
                        spacing: 15
                        clip: true
                        interactive: true
                        ScrollBar.vertical: null
                        onMovementStarted: {   //Se identificar scroll automaticamente para com o scroll Automatico
                            scrollAutomate.stop()
                        }
                        onContentYChanged: {
                            // Se o scroll atual somado à altura da janela atingir ou passar o tamanho total do conteúdo
                            if (contentY + height >= contentHeight) {
                                contentY = contentHeight - height; // Estabiliza no final
                                scrollAutomate.stop();             // Para a automação
                            }
                        }

                        delegate: Column {
                            width: listViewEntity.width
                            spacing: 15
                            property var entityData: strapiModelHomePageEntity.get(0)

                            Column {
                                width: listViewEntity.width
                                spacing: 0
                                Text {
                                    text: entityData.nameEntity
                                    font.pixelSize: 18
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }

                                Text {
                                    text: entityData.nameEntity
                                    font.pixelSize: 14
                                    color: "gray"
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                            }

                            Image {
                                source: entityData.imageEntityUrl
                                width: parent.width
                                fillMode: Image.PreserveAspectFit
                                cache: false
                            }
                            Rectangle {
                                width: parent.width
                                height: 50
                                border.width: 0.5
                                border.color: "grey"
                                color: "lightgrey"

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 20

                                    Rectangle {
                                        id: playPauseButtonEntity
                                        width: 30
                                        height: 30
                                        radius: width / 2
                                        color: "white"
                                        border.width: 2
                                        border.color: "#C89B3C"

                                        property bool isPlaying: false

                                        Image {
                                            id: imgPlayAudioEntity
                                            source: "qrc:/images/images/PlayButton.png"
                                            width: 10
                                            height: 10
                                            visible: player.playbackState !== MediaPlayer.PlayingState
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Image {
                                            id: pouseButton
                                            source: "qrc:/images/pouse.png"
                                            width: 20
                                            height: 20
                                            visible: player.playbackState === MediaPlayer.PlayingState
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                playPauseButtonEntity.isPlaying = !playPauseButtonEntity.isPlaying

                                                if(imgPlayAudioEntity.visible) {
                                                    imgPlayAudioEntity.visible = false
                                                    pouseButton.visible = true
                                                    player.source = entityData.audio
                                                    player.play()
                                                    scrollAutomate.running = true
                                                } else {
                                                    imgPlayAudioEntity.visible = true
                                                    pouseButton.visible = false
                                                    player.pause()
                                                    scrollAutomate.running = false
                                                }
                                            }
                                        }
                                    }

                                    Rectangle {
                                        id: progressBarBackground
                                        width: recInformacoesAreas.width / 2
                                        height: 3
                                        color: "white"
                                        anchors.verticalCenter: parent.verticalCenter

                                        // 1. A BARRA DE PROGRESSO
                                        Rectangle {
                                            id: progressBarFill
                                            height: parent.height
                                            color: "#C89B3C"
                                            width: player.duration > 0 ? (player.position / player.duration) * parent.width : 0

                                            Behavior on width {
                                                // Desativamos a animação se o usuário estiver interagindo para evitar "atraso" visual
                                                enabled: !dragArea.pressed
                                                NumberAnimation { duration: 200; easing.type: Easing.Linear }
                                            }
                                        }

                                        // 2. A BOLA (CONTROLLER)
                                        Rectangle {
                                            id: ballProgressAudio
                                            width: 14 // Um pouco maior para facilitar o toque
                                            height: 14
                                            radius: 7
                                            color: "#C89B3C"
                                            y: (parent.height / 2) - (height / 2) // Centraliza verticalmente

                                            // Posicionamento X: Segue o fim da barra de progresso
                                            // Subtraímos metade da largura (width/2) para a bola ficar centralizada na ponta
                                            x: progressBarFill.width - (width / 2)

                                            MouseArea {
                                                id: dragArea
                                                anchors.fill: parent
                                                anchors.margins: -10 // Aumenta a área de toque sem aumentar a bola
                                                drag.target: ballProgressAudio
                                                drag.axis: Drag.XAxis
                                                drag.minimumX: - (ballProgressAudio.width / 2)
                                                drag.maximumX: progressBarBackground.width - (ballProgressAudio.width / 2)

                                                // Enquanto arrasta, atualiza a posição do áudio
                                                onPositionChanged: {
                                                    if (drag.active) {
                                                        updateAudioPosition()
                                                    }
                                                }

                                                // Se apenas clicar na bola
                                                onReleased: updateAudioPosition()

                                                function updateAudioPosition() {
                                                    if (player.duration > 0) {
                                                        // Calcula a porcentagem baseada no X da bola em relação ao fundo
                                                        let visualX = ballProgressAudio.x + (ballProgressAudio.width / 2)
                                                        let percentage = Math.max(0, Math.min(visualX / progressBarBackground.width, 1))
                                                        player.setPosition(percentage * player.duration)
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            z: -1 // Fica atrás da bola para não roubar o clique dela
                                            onClicked: (mouse) => {
                                                           if (player.duration > 0) {
                                                               let percentage = mouse.x / width
                                                               player.setPosition(percentage * player.duration)
                                                           }
                                                       }
                                        }
                                    }
                                }
                            }

                            Text {
                                id: welcomeEnMessagEntity
                                width: parent.width
                                text: entityData.welcome_message
                                wrapMode: Text.WordWrap
                                font.pixelSize: 14
                                elide: Text.ElideRight

                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: itemInfoArea
        width: recInformacoesAreas.width
        height: recInformacoesAreas.height
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: -220

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: recCloseInfoArea
            width: 60
            height: 40
            radius: 20
            border.width: 1
            color: "white"
            anchors.right: recInformacoesAreas.left
            anchors.rightMargin: -20
            anchors.top: recInformacoesAreas.top
            anchors.topMargin: 50

            Rectangle {
                id: informacoesArea
                width: 18
                height: 18
                radius: 150
                border.width: 2
                border.color: "#D4AF37"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 25

                Text {
                    id: i_Area
                    text: "X"
                    font.bold: true
                    color: "#D4AF37"
                    font.pixelSize: 13
                    anchors.centerIn: parent
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(itemInfoArea.anchors.rightMargin >= 0) {
                        itemInfoArea.anchors.rightMargin = -220
                        scrollAutomate.stop()
                        i_Area.text = "i"
                    } else {
                        itemInfoArea.anchors.rightMargin = 10
                        scrollAutomate.running = true
                        i_Area.text = "X"
                    }
                    listViewAreas.positionViewAtBeginning()
                }
            }
        }

        Rectangle {
            id: recInformacoesAreas
            width: recInformacoes
            height: homePageItem.height / 2
            border.width:1
            radius: 40

            ListView {
                id: listViewAreas
                anchors.fill: parent
                anchors.margins: 20
                model: selectedPinIndex >= 0 ? 1 : 0
                spacing: 15
                clip: true
                interactive: true
                ScrollBar.vertical: null
                onMovementStarted: scrollAutomate.stop() // Para se o user tocar na tela

                onContentYChanged: {
                    if (contentY + height >= contentHeight && contentHeight > height) {  //Deteta se ja mostrou todo o conteudo e para
                        scrollAutomate.stop();
                    }
                }

                delegate: Column {
                    width: listViewAreas.width
                    spacing: 15

                    property var areaData: strapiModelHomePageAreas.get(selectedPinIndex)

                    Column {
                        width: listViewAreas.width
                        spacing: 0
                        Text {
                            text: areaData.nameArea
                            font.pixelSize: 18
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: areaData.subtitleArea
                            font.pixelSize: 14
                            color: "gray"
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    Image {
                        source: areaData.imageAreaUrl
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        cache: true
                    }
                    Rectangle {
                        width: parent.width
                        height: 50
                        border.width: 0.5
                        border.color: "grey"
                        color: "lightgrey"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 20

                            Rectangle {
                                id: playPauseButtonArea
                                width: 30
                                height: 30
                                radius: width / 2
                                color: "white"
                                border.width: 2
                                border.color: "#C89B3C"

                                property bool isPlaying: false

                                Image {
                                    id: imgPlayAudioArea
                                    source: "qrc:/images/images/PlayButton.png"
                                    width: 10
                                    height: 10
                                    visible: true
                                    anchors.centerIn: parent
                                }

                                Image {
                                    id: pouseButtonArea
                                    source: "qrc:/images/pouse.png"
                                    width: 20
                                    height: 20
                                    visible: false
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if(imgPlayAudioArea.visible) {
                                            imgPlayAudioArea.visible = false
                                            pouseButtonArea.visible = true
                                        } else {
                                            imgPlayAudioArea.visible = true
                                            pouseButtonArea.visible = false
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: recInformacoesAreas.width / 2
                                height: 3
                                color: "white"
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

                    Text {
                        id: descricaoArea
                        width: parent.width
                        text: areaData.descriptionArea
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }



    Item {
        id: itemInfoItem
        width: recInformacoesItem.width
        height: recInformacoesItem.height
        visible: false
        anchors.right: parent.right
        anchors.rightMargin: -220

        Behavior on anchors.rightMargin {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: recCloseInfoItem
            width: 60
            height: 40
            radius: 20
            border.width: 1
            color: "white"
            anchors.right: recInformacoesItem.left
            anchors.rightMargin: -20
            anchors.top: recInformacoesItem.top
            anchors.topMargin: 50

            Rectangle {
                id: informacoesItem
                width: 18
                height: 18
                radius: 150
                border.width: 2
                border.color: "#D4AF37"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 25


                Text {
                    id: i_Item
                    text: "X"
                    font.bold: true
                    color: "#D4AF37"
                    font.pixelSize: 13
                    anchors.centerIn: parent
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(itemInfoItem.anchors.rightMargin >= 0) {
                        itemInfoItem.anchors.rightMargin = -220
                        scrollAutomate.stop()
                        i_Item.text = "i"
                    } else {
                        itemInfoItem.anchors.rightMargin = 10
                        scrollAutomate.running = true
                        i_Item.text = "X"
                    }
                    listViewItems.positionViewAtBeginning()
                }
            }
        }

        Rectangle {
            id: recInformacoesItem
            width: recInformacoes
            height: homePageItem.height / 2
            border.width:1
            radius: 40

            ListView {
                id: listViewItems
                anchors.fill: parent
                anchors.margins: 20
                model: selectedPinIndexItem >= 0 ? 1 : 0
                spacing: 15
                clip: true
                interactive: true
                ScrollBar.vertical: null
                onContentYChanged: {
                    if (contentY + height >= contentHeight && contentHeight > height) {
                        scrollAutomate.stop();
                    }
                }
                onMovementStarted: scrollAutomate.stop()

                delegate: Column {
                    width: listViewItems.width
                    spacing: 15

                    property var itemData: strapiModelHomePageItems.get(selectedPinIndexItem)

                    Column {
                        width: parent.width

                        Text {
                            text: itemData.nameItem
                            font.pixelSize: 18
                            font.bold: true
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    Image {
                        source: itemData.coverUrlItem
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        cache: true
                    }

                    Rectangle {
                        width: parent.width
                        height: 50
                        border.width: 0.5
                        border.color: "grey"
                        color: "lightgrey"

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
                                color: "white"
                                border.width: 2
                                border.color: "#C89B3C"

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
                                width: recInformacoesAreas.width / 2
                                height: 3
                                color: "white"
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

                    Text {
                        id: txtDescriptionItem
                        text: itemData.descriptionItem
                        wrapMode: Text.WordWrap
                        font.pixelSize: 14
                        maximumLineCount: 10
                        width: parent.width
                    }

                    // Image {
                    //     id: imgQrCode
                    //     width: 150
                    //     height: 150
                    //     source: itemData.qrCode
                    //     fillMode: Image.PreserveAspectFit
                    // }
                }
            }
        }
    }

    MediaPlayer {
        id: player
        audioOutput: AudioOutput {}
        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia) {
                // Quando acaba, garantimos que a barra volta ao início ou para
                player.stop()
                imgPlayAudioEntity.visible = true
                pouseButton.visible = false
            }
        }
    }
}
