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
    property string appRepo: ""
    property bool loading: true
    property bool isErrorOccured: false
    property string errorMessage:""

    property int appJSONId: -1;
    property int appImageJSONId: -1;

    property var appJSONData: ({});
    property var appImageJSONData: ({});

    Component.onCompleted: {
        downloadDetails();
    }

    QbRequest{
        id: downloader
        onResultReady: {
            var jdata;
            //console.log(rid);
            //console.log(result);
            if(appJSONId === rid){
                appJSONId = -1;
                jdata = JSON.parse(result);
                if(jdata["status_code"] === 200){
                    //ready for next phase
                    //console.log("Ready for next phase");
                    appJSONData = JSON.parse(QbCoreOne.fromBase64(jdata["data"]));
                    var d1 = downloader.get("https://raw.githubusercontent.com/"+appRepo+"/"+appVersion+"/appimage.json");
                    //console.log(JSON.stringify(d1));
                    appSingleView.appImageJSONId = d1["rid"];
                }
                else{
                    isErrorOccured = true;
                    loadingMessage.text = "Unknown error occured."
                }
            }

            if(appImageJSONId === rid){
                appImageJSONId = -1;
                jdata = JSON.parse(result);
                if(jdata["status_code"] === 200){
                    //ready for next phase
                    //console.log("Ready displaying data");
                    appImageJSONData = JSON.parse(QbCoreOne.fromBase64(jdata["data"]));
                    loading = false;
                    refreshDetails();
                }
                else{
                    isErrorOccured = true;
                    loadingMessage.text = "Unknown error occured."
                }
            }
        }
    }

    Page{
        id: appDetailsPage
        anchors.fill: parent
        visible: !loading
        clip: true
        Material.background: "transparent"
        Label{
            id: appDescription
        }
    }

    function refreshDetails(){
        appDescription.text = appJSONData["description"];
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
        var d1 = downloader.get("https://raw.githubusercontent.com/"+appRepo+"/"+appVersion+"/app.json");
        console.log(JSON.stringify(d1));
        appSingleView.appJSONId = d1["rid"];
    }
}
