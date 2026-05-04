#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSslConfiguration>
#include <QSslSocket>
#include <QQmlContext>
#include "FileHelper.h"
#include "QZXing.h"

int main(int argc, char *argv[])
{
    // Melhora a renderização em alguns dispositivos Android
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);

    // Configuração SSL para evitar erros em downloads HTTPS no Android
    QSslConfiguration sslConfig = QSslConfiguration::defaultConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyNone);
    QSslConfiguration::setDefaultConfiguration(sslConfig);

    QQmlApplicationEngine engine;

    // 1. Registo do QZXing para leitura de QR Code
    QZXing::registerQMLTypes();
    QZXing::registerQMLImageProvider(engine);

    // 2. Instanciar e expor o FileHelper ao QML
    FileHelper fileHelper;
    engine.rootContext()->setContextProperty("FileHelper", &fileHelper);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
