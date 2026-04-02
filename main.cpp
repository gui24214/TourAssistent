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

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // 1. Inicializa o modelo como vazio para evitar erros de "ReferenceError" no QML
    QVariantList emptyList;
    engine.rootContext()->setContextProperty("itemsModel", QVariant::fromValue(emptyList));

    // 2. Configura o gestor de pedidos HTTP
    QNetworkAccessManager manager;
    QUrl url("http://127.0.0.1:1337/api/items?filters[area][documentId][$eq]=d7lcz79bahhizx4v32dl0d7h&filters[locale][$eq]=en&populate=*"); //ver todas as areas
    QNetworkRequest request(url);
    QNetworkReply *reply = manager.get(request);

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

                // Selecino os campos que quero is buscar
                itemMap["id"] = obj["id"].toVariant();
                itemMap["name"] = obj["name"].toString();
                itemMap["description"] = obj["description"].toString();

                QJsonObject coverObj = obj["cover"].toObject();
                QString relativeUrl = coverObj["url"].toString();

                itemMap["cover"] = obj["cover"].toString();

                itemMap["coverUrl"] = "http://127.0.0.1:1337" + relativeUrl;

                itemMap["posX"] = obj["posX"].toDouble();
                itemMap["posY"] = obj["posY"].toDouble();

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
    const QUrl url_qml(QStringLiteral("qrc:/main.qml"));
    engine.load(url_qml);

    return app.exec();
}
