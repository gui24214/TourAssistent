#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QVariantList>

int items(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // 1. Inicializa o modelo como vazio para evitar erros de "ReferenceError" no QML
    QVariantList emptyList;
    engine.rootContext()->setContextProperty("itemsModel", QVariant::fromValue(emptyList));

    // 2. Configura o gestor de pedidos HTTP
    QNetworkAccessManager manager;
    QUrl url("http://127.0.0.1:1337/api/items?locale=pt"); //ver todas as areas
    //QUrl url("http://127.0.0.1:1337/api/items?filters[area][id][$eq]=16&populate=*");   //Verificar items de uma determinada area
    QNetworkRequest request(url);  //faz o pedido
    QNetworkReply *reply = manager.get(request); //recebe o pedido

    // 3. Conecta a resposta da API (Usamos &engine para poder atualizar o contexto)
    QObject::connect(reply, &QNetworkReply::finished, [reply, &engine]() {
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(data);
            QJsonObject root = doc.object();

            // Nota: Vai buscar ao Strapi os dados em root["data"]
            QJsonArray items = root["data"].toArray();

            QVariantList itemsList;

            for (const QJsonValue &v : items) {
                QJsonObject obj = v.toObject();
                QVariantMap itemMap;

                // Se o teu JSON for do Strapi, os campos estão dentro de "attributes"
                // Caso contrário, usa apenas obj["id"], etc.
                itemMap["id"] = obj["id"].toVariant();
                itemMap["name"] = obj["name"].toString();
                itemMap["description"] = obj["description"].toString();

                itemsList.append(itemMap);
            }

            // Atualiza a propriedade no contexto para o QML reagir aos novos dados
            engine.rootContext()->setContextProperty("itemsModel", QVariant::fromValue(itemsList));
            qDebug() << "Dados carregados com sucesso. Itens:" << itemsList.size();
        } else {
            qDebug() << "Erro na API:" << reply->errorString();
        }
        reply->deleteLater();
    });

    // 4. Carrega o QML
    const QUrl url_qml(QStringLiteral("qrc:/Items.qml"));
    engine.load(url_qml);

    return app.exec();
}
