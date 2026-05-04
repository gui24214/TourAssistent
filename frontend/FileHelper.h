#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QStringList>

class FileHelper : public QObject
{
    Q_OBJECT

public:
    explicit FileHelper(QObject *parent = nullptr);

    // Q_INVOKABLE permite que estas funções sejam chamadas a partir do JS no QML
    Q_INVOKABLE void downloadFiles(QStringList urls, QString baseUrl, QString lang);
    Q_INVOKABLE QString getLocalMediaFolder(QString lang);
};

#endif // FILEHELPER_H
