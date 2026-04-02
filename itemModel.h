#pragma once
#include <QObject>
#include <QVariantList>

class ItemModel : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList items READ items NOTIFY itemsChanged)
public:
    explicit ItemModel(QObject *parent = nullptr);
    QVariantList items() const;
    void setItems(const QVariantList &list);

signals:
    void itemsChanged();

private:
    QVariantList m_items;
};
