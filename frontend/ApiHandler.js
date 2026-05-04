.import QtQuick.LocalStorage 2.0 as LS

var cache = {}
//var baseUrl = "http://192.168.1.72:1337" // ANDROID CASA
//var baseUrl = "http://10.241.233.27:1337/" // ANDROID ESTAGIO
var baseUrl = "http://127.0.0.1:1337/" // DESKTOP

function resolveUrl(path, localPath) {
    if (!path) return "";
    if (localPath) {
        var fileName = path.split("/").pop();

        return localPath + fileName;
    }
    return baseUrl + path;
}

function getData(lang, callback) {
    var db = LS.LocalStorage.openDatabaseSync("AppDB", "1.0", "Cache", 1000000)

    db.transaction(function(tx) {
        tx.executeSql("CREATE TABLE IF NOT EXISTS cache(lang TEXT, data TEXT)")
        var rs = tx.executeSql("SELECT data FROM cache WHERE lang=?", [lang])
        if (rs.rows.length > 0) {
            var dataFromDB = JSON.parse(rs.rows.item(0).data)
            callback(dataFromDB)
        }
    })

    var url = baseUrl + "api/entidades?locale=" + lang + "&populate[imageEntity]=true&populate[audio]=true&populate[tours][populate][imageTour]=true&populate[tours][populate][maps]=true&populate[tours][populate][items][populate][coverItem]=true&populate[maps][populate][imageMap]=true&populate[maps][populate][areas][populate][imageArea]=true&populate[maps][populate][areas][populate][items][populate][coverItem]=true"

    var xhr = new XMLHttpRequest()
    xhr.open("GET", url, true)
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText)
                    var dados = response.data
                    db.transaction(function(tx) {
                        tx.executeSql("DELETE FROM cache WHERE lang=?", [lang])
                        tx.executeSql("INSERT INTO cache VALUES(?, ?)", [lang, JSON.stringify(dados)])
                    });
                    callback(dados)
                } catch (e) { console.error("Erro JSON:", e) }
            }
        }
    }
    xhr.send()
}

function getEntities(dados, localPath) {
    var entidades = []
    if (!dados || dados.length === 0) return entidades
    var rawData = Array.isArray(dados) ? dados[0] : dados;
    var entidade = (rawData && rawData.attributes) ? rawData.attributes : rawData;

    if (entidade) {
        var imgPath = (entidade.imageEntity?.data?.attributes?.url) || entidade.imageEntity?.url;
        var audioPath = (entidade.audio?.data?.attributes?.url) || entidade.audio?.url;

        entidades.push({
                           "nameEntity": entidade.nameEntity || "",
                           "descriptionEntity": entidade.descriptionEntity || "",
                           "welcome_message": entidade.welcome_message || "",
                           "audio": resolveUrl(audioPath, localPath),
                           "imageEntityUrl": resolveUrl(imgPath, localPath)
                       })
    }
    return entidades
}

function getMaps(dados, localPath) {
    var maps = []
    if (!dados || dados.length === 0) return maps
    var rawData = Array.isArray(dados) ? dados[0] : dados;
    var entidade = (rawData && rawData.attributes) ? rawData.attributes : rawData;

    if (entidade && entidade.maps) {
        for (var i = 0; i < entidade.maps.length; i++) {
            var mapa = entidade.maps[i]
            var imgPath = mapa.imageMap?.data?.attributes?.url || mapa.imageMap?.url;
            maps.push({
                          "floorMap": mapa.floorMap || "",
                          "imageMapUrl": resolveUrl(imgPath, localPath)
                      })
        }
    }
    return maps
}

function getAreas(dados, localPath) {
    var areas = []
    if (!dados || dados.length === 0) return areas
    var rawData = Array.isArray(dados) ? dados[0] : dados;
    var entidade = (rawData && rawData.attributes) ? rawData.attributes : rawData;

    if (entidade && entidade.maps) {
        for (var i = 0; i < entidade.maps.length; i++) {
            var mapa = entidade.maps[i]
            if (mapa.areas) {
                for (var j = 0; j < mapa.areas.length; j++) {
                    var area = mapa.areas[j]
                    var imgPath = area.imageArea?.data?.attributes?.url || area.imageArea?.url;
                    areas.push({
                                   "nameArea": area.nameArea || "",
                                   "subtitleArea": area.subtitleArea || "",
                                   "descriptionArea": area.descriptionArea || "",
                                   "posX": area.posX || 0,
                                   "posY": area.posY || 0,
                                   "imageAreaUrl": resolveUrl(imgPath, localPath),
                                   "mapIndex": i
                               })
                }
            }
        }
    }
    return areas
}

function getItems(dados, localPath) {
    var items = []
    if (!dados || dados.length === 0) return items
    var rawData = Array.isArray(dados) ? dados[0] : dados;
    var entidade = rawData.attributes ? rawData.attributes : rawData;

    if (entidade && entidade.maps) {
        for (var i = 0; i < entidade.maps.length; i++) {
            var mapa = entidade.maps[i]
            if (mapa.areas) {
                for (var j = 0; j < mapa.areas.length; j++) {
                    var area = mapa.areas[j]
                    if (area.items) {
                        for (var k = 0; k < area.items.length; k++) {
                            var item = area.items[k]
                            var imgPath = item.coverItem?.data?.attributes?.url || item.coverItem?.url;
                            items.push({
                                           "documentId": item.documentId || "",
                                           "nameItem": item.nameItem || "",
                                           "descriptionItem": item.descriptionItem || "",
                                           "posXItem": item.posXItem || 0,
                                           "posYItem": item.posYItem || 0,
                                           "coverUrlItem": resolveUrl(imgPath, localPath),
                                            qrCode: item.qrCode || "",
                                           "areaIndex": j,
                                           "mapIndex": i
                                       })
                        }
                    }
                }
            }
        }
    }
    return items
}


/* ================================
   HELPERS
================================ */

function getRootEntity(dados) {
    if (!dados || !Array.isArray(dados) || dados.length === 0) return null;
    var rawData = dados[0];
    return rawData.attributes ? rawData.attributes : rawData;
}

function findTourByIdOrDocumentId(dados, tourRef) {
    var entidade = getRootEntity(dados);
    if (!entidade || !entidade.tours) return null;

    var tours = Array.isArray(entidade.tours)
        ? entidade.tours
        : entidade.tours.data || [];

    for (var i = 0; i < tours.length; i++) {
        var t = tours[i];
        var data = t.attributes || t;

        if (data.id === tourRef || data.documentId === tourRef) {
            return data;
        }
    }
    return null;
}

function findFullMapByIdOrDocumentId(dados, mapRef) {
    var entidade = getRootEntity(dados);
    if (!entidade || !entidade.maps) return null;

    for (var i = 0; i < entidade.maps.length; i++) {
        var mapa = entidade.maps[i];
        if (mapa.id === mapRef || mapa.documentId === mapRef) {
            return mapa;
        }
    }
    return null;
}

/* ================================
   TOUR ITEMS
================================ */

function getTourItems(dados, tourRef, localPath) {
    var items = [];

    var entidade = getRootEntity(dados);
    if (!entidade || !entidade.tours) return items;

    var tours = Array.isArray(entidade.tours)
        ? entidade.tours
        : entidade.tours.data || [];

    var tour = null;

    for (var i = 0; i < tours.length; i++) {
        var t = tours[i];
        var data = t.attributes ? t.attributes : t;

        if (data.id === tourRef || data.documentId === tourRef) {
            tour = data;
            break;
        }
    }

    if (!tour || !tour.items) return items;

    var rawItems = Array.isArray(tour.items)
        ? tour.items
        : tour.items.data || [];

    for (var i = 0; i < rawItems.length; i++) {
        var item = rawItems[i];
        var data = item.attributes ? item.attributes : item;

        var imgPath =
            data.coverItem?.data?.attributes?.url ||
            data.coverItem?.url ||
            "";

        items.push({
            id: data.id || 0,
            documentId: data.documentId || "",
            nameItem: data.nameItem || "",
            descriptionItem: data.descriptionItem || "",
            posXItem: data.posXItem || 0,
            posYItem: data.posYItem || 0,
            coverUrlItem: resolveUrl(imgPath, localPath)
        });
    }

    return items;
}
/*==============================================TOURS===========================================================================================*/
// Adicione os parâmetros (dados, localPath) que você está a passar no QML
function getTours(dados, localPath) {
    var tours = [];

    var entidade = getRootEntity(dados);
    if (!entidade || !entidade.tours) return tours;

    var rawTours =
        entidade.tours ||
        entidade.tours?.data;

    var list = Array.isArray(rawTours) ? rawTours : [rawTours];

    for (var i = 0; i < list.length; i++) {

        var item = list[i];
        var data = item.attributes || item;

        var rawItems =
            data.items ||
            data.items?.data;

        var totalParagens = rawItems
            ? (Array.isArray(rawItems) ? rawItems.length : 1)
            : 0;

        var imgPath =
            data.imageTour?.data?.attributes?.url ||
            data.imageTour?.url ||
            "";

        tours.push({
            id: data.id || 0,
            documentId: data.documentId || "",
            nameTour: data.nameTour || "Sem nome",
            timeTour: data.timeTour || "",
            descriptionTour: data.descriptionTour || "",
            imageTour: resolveUrl(imgPath, localPath),
            totalStops: totalParagens
        });
    }

    return tours;
}

function extractMediaUrls(dados) {
    var urls = []
    if (!dados || dados.length === 0) return urls
    var rawData = Array.isArray(dados) ? dados[0] : dados
    var entidade = rawData.attributes ? rawData.attributes : rawData
    if (!entidade) return urls

    // 1. Imagem e Áudio da Entidade
    if (entidade.imageEntity) {
        var img = entidade.imageEntity.data?.attributes?.url || entidade.imageEntity.url
        if (img) urls.push(img)
    }
    if (entidade.audio) {
        var audio = entidade.audio.data?.attributes?.url || entidade.audio.url
        if (audio) urls.push(audio)
    }

    // 2. TOURS (Aqui estava o problema)
    if (entidade.tours) {
        var tourArray = Array.isArray(entidade.tours) ? entidade.tours : [entidade.tours];
        for (var t = 0; t < tourArray.length; t++) {
            var tour = tourArray[t];

            // Imagem do Tour
            var tourImg = tour.imageTour?.data?.attributes?.url || tour.imageTour?.url;
            if (tourImg) urls.push(tourImg);

            // --- NOVO: Percorrer Itens do Tour ---
            if (tour.items && Array.isArray(tour.items)) {
                for (var ti = 0; ti < tour.items.length; ti++) {
                    var tourItem = tour.items[ti];
                    var tourItemImg = tourItem.coverItem?.data?.attributes?.url || tourItem.coverItem?.url;
                    if (tourItemImg) urls.push(tourItemImg);
                }
            }
        }
    }

    // 3. MAPAS, ÁREAS e ITENS (via Mapas)
    if (entidade.maps) {
        for (var i = 0; i < entidade.maps.length; i++) {
            var mapa = entidade.maps[i]
            if (mapa.imageMap) {
                var mapImg = mapa.imageMap.data?.attributes?.url || mapa.imageMap.url
                if (mapImg) urls.push(mapImg)
            }
            if (mapa.areas) {
                for (var j = 0; j < mapa.areas.length; j++) {
                    var area = mapa.areas[j]
                    if (area.imageArea) {
                        var areaImg = area.imageArea.data?.attributes?.url || area.imageArea.url
                        if (areaImg) urls.push(areaImg)
                    }
                    if (area.items) {
                        for (var k = 0; k < area.items.length; k++) {
                            var item = area.items[k]
                            if (item.coverItem) {
                                var itemImg = item.coverItem.data?.attributes?.url || item.coverItem.url
                                if (itemImg) urls.push(itemImg)
                            }
                        }
                    }
                }
            }
        }
    }

    return urls
}
