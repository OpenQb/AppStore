import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import Qb 1.0
import Qb.Core 1.0

Page {
    id: appSingleView
    property string appName: ""
    property string appVersion: ""
    property string appNameSpace: ""
    property bool loading: true
    property bool isErrorOccured: false

    Component.onCompleted: {
        //mainTimer.start();
    }

    QbRequest{

    }

    Page{
        id: loadingPage
        anchors.fill: parent
        visible: loading
        Material.background: "transparent"

        Label{
            id: loadingMessage
            text: "Loading"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
        }

        PageIndicator{
            id: loadingProgress
            visible: appSingleView.loading
            count: 4
            anchors.top: loadingMessage.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item{
            anchors.top: loadingProgress.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: QbCoreOne.scale(50)
            visible: appSingleView.isErrorOccured
            Row{
                anchors.centerIn: parent
                spacing: QbCoreOne.scale(10)
                Button{
                    id: reloadButton
                    text: "RELOAD"
                    Material.background: appTheme.lighter(appTheme.accent,150)
                    onClicked: {
                        downloadDetails();
                    }
                }
                Button{
                    id: backButton
                    text: "BACK"
                    Material.background: appTheme.lighter(appTheme.accent,150)
                    onClicked: {
                        if(appStackView.depth>1) appStackView.pop();
                    }
                }
            }
        }
    }

    Timer{
        id: mainTimer
        interval: 500
        repeat: true
        running: true
        triggeredOnStart: true
        property int counter: 0
        onTriggered: {
            if(appSingleView.loading && !appSingleView.isErrorOccured){
                if(counter === 3){
                    counter = 0;
                    loadingProgress.currentIndex = counter;
                }
                else{
                    counter++;
                    loadingProgress.currentIndex = counter;
                }
            }
        }
    }


    function downloadDetails(){
        appSingleView.loading = true;
        loadingMessage.text = "Loading"
    }
}
