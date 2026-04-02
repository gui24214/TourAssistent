#include "ItemModel.h"

ItemModel::ItemModel(QObject *parent) : QObject(parent) {}

QVariantList ItemModel::items() const { return m_items; }

void ItemModel::setItems(const QVariantList &list) {
    if (m_items != list) {
        m_items = list;
        emit itemsChanged();
    }
}
