import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtMultimedia

Rectangle {
    id: root
    width: 60
    height: 60
    radius: 50
    color: "black"
    z: 9999

    Image {
        anchors.centerIn: parent
        width: 30
        height: 30
        source: "qrc:/images/images/qrCode.png"
    }
}
