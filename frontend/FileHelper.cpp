#include "FileHelper.h"
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>
#include <QUrl>

FileHelper::FileHelper(QObject *parent) : QObject(parent) {}

void FileHelper::downloadFiles(QStringList urls, QString baseUrl, QString lang)
{
    if (urls.isEmpty()) return;

    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QString basePath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/media/" + lang;

    if (!QDir().mkpath(basePath)) {
        qDebug() << "Erro ao criar pasta:" << basePath;
    }

    for (const QString &url : urls) {
        if (url.isEmpty()) continue;

        QString fullUrl = baseUrl + url;
        QString fileName = url.split("/").last();
        QString filePath = basePath + "/" + fileName;

        if (QFile::exists(filePath)) {
            qDebug() << "Já existe:" << filePath;
            continue;
        }

        QNetworkRequest request((QUrl(fullUrl)));
        QNetworkReply *reply = manager->get(request);

        connect(reply, &QNetworkReply::finished, [reply, filePath]() {
            if (reply->error() == QNetworkReply::NoError) {
                QFile file(filePath);
                if (file.open(QIODevice::WriteOnly)) {
                    file.write(reply->readAll());
                    file.close();
                    qDebug() << "Guardado com sucesso:" << filePath;
                }
            } else {
                qDebug() << "Erro no download de" << filePath << ":" << reply->errorString();
            }
            reply->deleteLater();
        });
    }
}

QString FileHelper::getLocalMediaFolder(QString lang)
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/media/" + lang;
    return QUrl::fromLocalFile(path).toString() + "/";
}
