import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import Qb 1.0
import Qb.Core 1.0

import "ljs/uicontroller.js" as LUiController

Page {
    id: appSingleView
    clip: true
    property string appName: ""
    property string appRepo: ""
    property string appVersion: ""
    property string appNameSpace: ""

    property bool loading: true
    property bool isErrorOccured: false
    property bool latest: false
    property string errorMessage:""

    property int appJSONId: -1;
    property int appImageJSONId: -1;
    property int versionCollectorId: -1;

    property var appJSONData: ({});
    property var appImageJSONData: ({});

    signal showImageFullScreen(string src);

    Component.onCompleted: {
        downloadDetails();
    }

    onShowImageFullScreen: {
        fullScreenImage.openWithImage(src);
    }

    Popup {
        id: fullScreenImage
        x: (parent.width - width)/2.0
        y: (parent.height - height)/2.0
        width: parent.width*0.90
        height: parent.height*0.90
        modal: true
        focus: true
        topPadding: 0
        bottomPadding: 0
        rightPadding: 0
        leftPadding: 0
        Material.background: appTheme.primary

        Image{
            id: fImage
            fillMode: Image.Image.PreserveAspectFit
            width: parent.width*0.90
            height: parent.height*0.90
            anchors.centerIn: parent
        }

        function openWithImage(src){
            fImage.source = src;
            fullScreenImage.open();
        }
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

            if(versionCollectorId === rid){
                versionCollectorId = -1;
                jdata = JSON.parse(result);
                if(jdata["status_code"] === 200){
                    //ready for next phase
                    //console.log("Ready displaying data");
                    var vd = JSON.parse(QbCoreOne.fromBase64(jdata["data"]));
                    if(vd["tag_name"] !== undefined){
                        appSingleView.appVersion = vd["tag_name"];
                    }

                    var d3 = downloader.get("https://raw.githubusercontent.com/"+appRepo+"/"+appVersion+"/app.json");
                    //console.log(JSON.stringify(d1));
                    appSingleView.appJSONId = d3["rid"];
                }
                else{
                    isErrorOccured = true;
                    loadingMessage.text = "Unknown error occured."
                }
            }

        }
    }
    ToolBar{
        id: toolBar
        anchors.top:parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        //Material.background: "transparent"

        ToolButton{
            id: prevPage
            text: QbMF3.icon("mf-keyboard_arrow_left")
            font.family: QbMF3.family
            font.bold: true
            width: QbCoreOne.scale(50)
            height: QbCoreOne.scale(50)
            onClicked: {
                appUi.pop()
            }
        }
        Label{
            anchors.fill: parent
            font.bold: true
            anchors.centerIn: parent
            verticalAlignment: Label.AlignVCenter
            horizontalAlignment: Label.AlignHCenter
            text: appName
        }
    }

    Page{
        id: appDetailsPage

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom

        visible: !loading
        clip: true
        Material.background: "transparent"

        Column{
            anchors.fill: parent
            spacing: QbCoreOne.scale(10)

            Item{
                id: topPlaceHolder
                width: parent.width
                height: 200
                property color textColor: appTheme.foreground
                Image{
                    id: appIconImage
                    anchors.left: parent.left
                    anchors.leftMargin: QbCoreOne.scale(5)
                    anchors.verticalCenter: parent.verticalCenter
                    width: QbCoreOne.scale(150)
                    smooth: true
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                    height: QbCoreOne.scale(150)
                    source: "https://raw.githubusercontent.com/"+appRepo+"/"+appVersion+"/app.png"
                }

                Item{
                    id: textPlaceHolder
                    anchors.top: parent.top
                    anchors.topMargin: (topPlaceHolder.height - appIconImage.height)/2.0
                    anchors.left: appIconImage.right
                    anchors.leftMargin: QbCoreOne.scale(5)
                    anchors.right: parent.right
                    height: appIconImage.height
                    clip: true
                    Column{
                        anchors.fill: parent
                        Label{
                            text: appName
                            color: topPlaceHolder.textColor
                            width: parent.width
                            font.bold: true
                        }
                        Label{
                            width: parent.width
                            text: appVersion
                            color: appTheme.darker(topPlaceHolder.textColor,150)
                            font.bold: true
                        }
                        Label{
                            text: appRepo
                            color: appTheme.darker(topPlaceHolder.textColor,150)
                            width: parent.width
                            elide: Label.ElideMiddle
                            font.bold: true
                        }
                        Label{
                            width: parent.width
                            text: appNamespace
                            color: appTheme.darker(topPlaceHolder.textColor,150)
                            font.bold: true
                        }

                        Button{
                            id: downloadButton
                            enabled: false
                            text: "install"//appStorage.properTextForDownload(appNameSpace,appVersion)
                            Material.background: appTheme.lighter(appTheme.primary,150)
                            onClicked: {
                                if(downloadButton.text === "cancel"){
                                    cancelDownload();
                                }
                                else{
                                    downloadApp();
                                }
                                downloadButtonUpdate();
                            }
                        }
                    }
                }
            }

            Item{
                id: middlePlaceHolder
                height: flickArea.height
                anchors.left: parent.left
                anchors.leftMargin: QbCoreOne.scale(10)
                anchors.right: parent.right
                anchors.rightMargin: QbCoreOne.scale(10)
                Flickable {
                    id: flickArea
                    clip: true
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    flickableDirection: Flickable.VerticalFlick
                    pixelAligned: true
                    height: Math.min(QbCoreOne.scale(300),contentHeight)

                    contentHeight: appDescription.height
                    contentWidth: parent.width
                    TextEdit {
                        id: appDescription
                        width: parent.width
                        clip: true
                        textFormat: TextArea.RichText
                        readOnly: true
                        focus: false
                        color: topPlaceHolder.textColor
                        font.pixelSize: QbCoreOne.scale(15)
                        wrapMode: Text.Wrap
                        activeFocusOnPress: false
                        textMargin: 0
                    }
                }
            }

            Item{
                id: bottomPlaceHolder
                anchors.left: parent.left
                anchors.leftMargin: QbCoreOne.scale(10)
                anchors.right: parent.right
                anchors.rightMargin: QbCoreOne.scale(10)
                height:  parent.height - topPlaceHolder.height - middlePlaceHolder.height
                ListView{
                    id: screenShotList
                    property var m: []
                    model: screenShotList.m;
                    anchors.fill: parent
                    orientation: ListView.Horizontal

                    delegate: Image{
                        source: screenShotList.m[index]
                        width: parent.height
                        height: width
                        fillMode: Image.PreserveAspectFit

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                appSingleView.showImageFullScreen(screenShotList.m[index]);
                            }
                        }
                    }
                }
            }
        }
    }

    function downloadApp(){
        LUiController.downloadApp(appSingleView.appNameSpace,
                                  appSingleView.appRepo,
                                  appSingleView.appVersion);
    }
    function cancelDownload(){
        LUiController.cancelDownload(appSingleView.appNameSpace)
    }
    function isDownloading(){
        return LUiController.isDownloading(appSingleView.appNameSpace)
    }

    function isCurrentOsSupported(lst){
        return lst.indexOf(Qt.platform.os) !== -1;
    }

    function downloadButtonUpdate(){
        downloadButton.enabled = isCurrentOsSupported(appJSONData["supportedOs"]);
        if(isDownloading()){
            downloadButton.text = "cancel";
        }
        else{
            downloadButton.text = appStorage.properTextForDownload(appSingleView.appNameSpace,appSingleView.appVersion);
        }
    }

    function refreshDetails(){
        var rText = appJSONData["description"];
        var supportedOs = appJSONData["supportedOs"];
        rText = rText+"<br/><br/>"+"<b>Supported os: "+supportedOs.join()+"</b>";
        //appDescription.text = appJSONData["description"];
        appSingleView.appName = appJSONData["name"];
        appSingleView.appVersion = appJSONData["version"];
        appDescription.text = rText;

        var m = [];
        for(var i=0;i<appImageJSONData["screenshotList"].length;++i){
            m.push(appImageJSONData["screenshotList"][i][1]);
        }
        screenShotList.m = m;
        downloadButtonUpdate();
    }

    Page{
        id: loadingPage
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolBar.bottom
        anchors.bottom: parent.bottom
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
        appSingleView.versionCollectorId = -1;
        appSingleView.appJSONId = -1;
        appSingleView.appImageJSONId = -1;
        appSingleView.loading = true;
        loadingMessage.text = "Loading";
        if(appSingleView.latest){
            //https://api.github.com/repos/mkawserm/2048/releases/latest
            var d2 = downloader.get("https://api.github.com/repos/"+appRepo+"/releases/latest");
            //console.log(JSON.stringify(d1));
            appSingleView.versionCollectorId = d2["rid"];
        }
        else{
            var d1 = downloader.get("https://raw.githubusercontent.com/"+appRepo+"/"+appVersion+"/app.json");
            //console.log(JSON.stringify(d1));
            appSingleView.appJSONId = d1["rid"];
        }
    }
}
