import QtQuick 2.10
import QtGraphicalEffects 1.0

Item {
    property Item translucencySource
    property color backgroundColor: "black"
    property real backgroundColorOpacity: 0.2
    property real blurOpacity: 1
    property int blurRadious: 10
    property int itemRadious: 5
    property color borderColor: "red"
    property int borderWidth: 10
    visible: true

    id: _root

    Rectangle{
        id: _rectangleSource
        anchors.fill: parent
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: _root.width
                height: _root.height
                Rectangle {
                    anchors.centerIn: parent
                    width: _root.width
                    height: _root.height
                    radius: _root.itemRadious
                }
            }
        }

        GaussianBlur {
            width: _root.width
            height: _root.height
            //source: translucencySource
            samples: 32
            deviation: 7
            opacity: blurOpacity
            radius: blurRadious
            source: ShaderEffectSource {
                sourceItem: translucencySource
                width: _root.width;height: _root.height;
                sourceRect: Qt.rect(_root.x, _root.y, _root.width, _root.height)
                visible: false
            }
        }

        Rectangle{
            id: _background
            anchors.fill: parent
            color: _root.backgroundColor
            opacity: _root.backgroundColorOpacity
        }

    }
}
