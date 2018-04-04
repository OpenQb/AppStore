import Qb 1.0
import Qb.Core 1.0
import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

ListView{
    clip: true
    signal categorySelected(string category);
    property int selectedIndex: -1;

    delegate: Rectangle{
        width: parent.width
        height: QbCoreOne.scale(50)
        color: appTheme.changeTransparency(appTheme.background,100)
        Rectangle{
            width: parent.width
            height: QbCoreOne.scale(2)
            visible: index === selectedIndex;
            color: appTheme.isDark(appTheme.primary)?appTheme.lighter(appTheme.accent,200):appTheme.lighter(appTheme.accent,100)
            anchors.bottom: parent.bottom
        }

        Label{
            text: name
            anchors.fill: parent
            verticalAlignment: Label.AlignVCenter
            anchors.leftMargin: QbCoreOne.scale(10)
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    selectedIndex = index;
                    categorySelected(name);
                }
            }
        }
    }
}
