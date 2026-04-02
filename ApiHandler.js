    .import QtQuick.LocalStorage 2.0 as LS

    var cache = null

    function getData(lang, callback) {

        // Ver se já está em memória
        if (cache !== null) {
            console.log("MEMÓRIA")
            callback(cache)
            return
        }

        //Ver cache local
        var db = LS.LocalStorage.openDatabaseSync("AppDB", "1.0", "Cache", 1000000)

        var dataFromDB = null

        db.transaction(function(tx) {
            tx.executeSql("CREATE TABLE IF NOT EXISTS cache(lang TEXT, data TEXT)")
            var rs = tx.executeSql("SELECT data FROM cache WHERE lang=?", [lang])

            if (rs.rows.length > 0) {
                dataFromDB = JSON.parse(rs.rows.item(0).data)
            }
        })

        if (dataFromDB !== null) {
            console.log("CACHE LOCAL")
            cache = dataFromDB
            callback(cache)
            return
        }

        //Se não existir dados vai á API
        console.log("API")
        var xhr = new XMLHttpRequest()

        var url = "http://127.0.0.1:1337/api/entidades"+ "?locale=" + lang + "&populate[maps][populate][areas][populate][items][populate]=*"

        xhr.open("GET", url)

        xhr.onreadystatechange = function() {

            if (xhr.readyState === XMLHttpRequest.DONE) {

                if (xhr.status === 200) {

                    var response = JSON.parse(xhr.responseText)
                    var dados = response.data

                    // guardar em memória
                    cache = dados

                    // guardar no disco
                    db.transaction(function(tx) {
                        tx.executeSql("DELETE FROM cache WHERE lang=?", [lang])
                        tx.executeSql("INSERT INTO cache VALUES(?, ?)", [lang, JSON.stringify(dados)])
                    })

                    callback(dados)
                    console.log("URL:", url)

                } else {
                    console.error("Erro API")
                    callback([])
                }
            }
        }

        xhr.send()
    }

function getItems(dados) {

    var items = []

    if (!dados || dados.length === 0)
        return items

    var entidade = dados[0]

    for (var i = 0; i < entidade.maps.length; i++) {
        var mapa = entidade.maps[i]

        for (var j = 0; j < mapa.areas.length; j++) {
            var area = mapa.areas[j]

            for (var k = 0; k < area.items.length; k++) {

                var item = area.items[k]

                items.push({
                    nameItem: item.nameItem || "",
                    descriptionItem: item.descriptionItem || "",
                    posXItem: item.posXItem || 0,
                    posYItem: item.posYItem || 0,
                    coverUrlItem: (item.coverItem && item.coverItem.url)
                        ? "http://127.0.0.1:1337" + item.coverItem.url
                        : ""
                })
            }
        }
    }

    return items
}
