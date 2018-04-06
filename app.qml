import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import Qb 1.0
import Qb.Core 1.0

import "ljs/qbapp.js" as LApp
import "ljs/uicontroller.js" as LUiController

QbApp {
    id: appUi

    onAppClosing: {
        try{
            appDownloadManagerUi.close();
            appDownloadManagerUi.destroy();
        }
        catch(e){
        }

        try{
            menuDrawer.close();
            menuDrawer.destroy();
        }
        catch(e){
        }

    }

    QbMetaTheme{
        id: appTheme
    }

    QbAppStorage{
        id: appStorage
    }

    ListModel{
        id: appDownloadManagerModel
    }

    Image {
        id: appBackground
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        width: parent.width
        height: parent.height
        source: appUi.getDefaultBackgroundImageURL()
        visible: true
    }

    Component.onCompleted: {
        /*dummy test data*/
        //        appDownloadManagerModel.append(
        //                    {
        //                        "name":"2048",
        //                        "namespace":"com.github.com",
        //                        "repo":"mkawserm/2048",
        //                        "version":"1.0.5",
        //                        "isDownloading":true,
        //                        "msg":"",
        //                        "totalReceived": "O KB"
        //                    }
        //                    );

        /* setting up everything */
        var backGroundImage = String(appUi.getDefaultBackgroundImageURL());
        appTheme.setImageFromPath(backGroundImage.substring(3,backGroundImage.length));
        LApp.setup(appUi);
        LUiController.appUi = appUi;
        LUiController.appListView = appListView;
        LUiController.appStackView = appStackView;
        LUiController.fileObject = fileObject;
        LUiController.engineObject = engineObject;
        LUiController.appDownloadManagerUi = appDownloadManagerUi;
        LUiController.appDownloadManagerModel = appDownloadManagerModel;
        LUiController.appStorage = appStorage;
        LUiController.qbCoreOne = QbCoreOne;

        LUiController.setup();
    }


    QbQJSEngine{
        id: engineObject
        onMessage: {
            LUiController.readyXEngineResult(data);
        }
    }

    QbFile{
        id: fileObject
    }

    Popup {
        id: appDownloadManagerUi
        x: (parent.width - width)/2.0
        y: (parent.height - height)/2.0
        width: parent.width*0.90
        height: parent.height*0.90
        modal: true
        focus: true
        topPadding: QbCoreOne.scale(10)
        bottomPadding: QbCoreOne.scale(10)
        rightPadding: QbCoreOne.scale(10)
        leftPadding: QbCoreOne.scale(10)
        background: TranslucentGlass{
            translucencySource: appBackground
            backgroundColorOpacity: 0.7
        }

        ListView{
            clip: true
            anchors.fill: parent
            model: appDownloadManagerModel

            delegate: Item{
                width: parent.width
                height: QbCoreOne.scale(100)
                Rectangle{
                    anchors.fill: parent
                    color: "transparent"
                    border.width: QbCoreOne.scale(1)
                    border.color: topPlaceHolder.textColor
                    radius: QbCoreOne.scale(5)
                    Item{
                        id: topPlaceHolder
                        width: parent.width
                        height: parent.height
                        anchors.top: parent.top
                        anchors.topMargin: QbCoreOne.scale(10)
                        property color textColor: appTheme.foreground
                        Image{
                            id: appIconImage
                            anchors.left: parent.left
                            anchors.leftMargin: QbCoreOne.scale(5)
                            //anchors.verticalCenter: parent.verticalCenter
                            width: QbCoreOne.scale(64)
                            smooth: true
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                            height: QbCoreOne.scale(64)
                            source: "https://raw.githubusercontent.com/"+repo+"/"+version+"/app.png"
                        }

                        Item{
                            id: textPlaceHolder
                            anchors.top: parent.top
                            anchors.left: appIconImage.right
                            anchors.leftMargin: QbCoreOne.scale(5)
                            anchors.right: parent.right
                            height: parent.height
                            clip: true
                            Column{
                                anchors.fill: parent
                                Label{
                                    text: name
                                    color: topPlaceHolder.textColor
                                    width: parent.width
                                    font.bold: true
                                }
                                Label{
                                    width: parent.width
                                    text: version
                                    color: appTheme.darker(topPlaceHolder.textColor,150)
                                    font.bold: true
                                }
                                Label{
                                    text: repo
                                    color: appTheme.darker(topPlaceHolder.textColor,150)
                                    width: parent.width
                                    elide: Label.ElideMiddle
                                    font.bold: true
                                }
                                Label{
                                    width: parent.width
                                    text: namespace
                                    color: appTheme.darker(topPlaceHolder.textColor,150)
                                    font.bold: true
                                }
                                Row{
                                    width: parent.width
                                    spacing: QbCoreOne.scale(10)
                                    Label{
                                        id: spinnerLabel
                                        width: QbCoreOne.scale(15)
                                        height: QbCoreOne.scale(15)
                                        //anchors.left: parent.left
                                        font.family: QbFA.family
                                        text: QbFA.icon("fa-spinner")
                                        font.pixelSize: width
                                        visible: isDownloading
                                        RotationAnimation on rotation {
                                            loops: Animation.Infinite
                                            running: isDownloading
                                            duration: 1000
                                            from: 0
                                            to: 360
                                        }
                                    }
                                    Label{
                                        width: parent.width - spinnerLabel.width
                                        text: totalReceived
                                        font.bold: false
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }
        /***All Download Manager Methods will be here****/

    }

    Drawer {
        id: menuDrawer
        width: Math.min(0.66 * appListView.width,400)
        height: parent.height
        y: 0
        clip: true
        background: TranslucentGlass{
            translucencySource: appBackground
            backgroundColor: appTheme.background
            backgroundColorOpacity: 1
            blurOpacity: 0.9
            blurRadious: 20
            itemRadious: 0//QbCoreOne.scale(10)
        }

        Column{
            anchors.fill: parent
            spacing: 0
            TabBar{
                id: menuDrawerTabBar
                width: parent.width
                Material.accent: appTheme.isDark(appTheme.primary)?appTheme.lighter(appTheme.accent,200):appTheme.lighter(appTheme.accent,100)
                Material.primary: appTheme.primary
                Material.background: appTheme.background
                Material.foreground: appTheme.foreground
                Material.theme: appTheme.theme==="dark"?Material.Dark:Material.Light
                TabButton {
                    text: qsTr("Apps")
                }
                TabButton {
                    text: qsTr("Games")
                }
                onCurrentIndexChanged: {
                    menuDrawerSwipeView.currentIndex = currentIndex;
                    appsGenreList.selectedIndex = -1;
                    gamesGenreList.selectedIndex = -1;
                }
            }

            SwipeView{
                id: menuDrawerSwipeView
                width: parent.width
                height: parent.height - menuDrawerTabBar.height - exitButton.height
                currentIndex: menuDrawerTabBar.currentIndex
                interactive: false
                clip: true
                Material.accent: appTheme.isDark(appTheme.primary)?appTheme.lighter(appTheme.accent,200):appTheme.lighter(appTheme.accent,100)
                Material.primary: appTheme.primary
                Material.background: appTheme.background
                Material.foreground: appTheme.foreground
                Material.theme: appTheme.theme==="dark"?Material.Dark:Material.Light

                CategoryList{
                    id: appsGenreList
                    onCategorySelected:{
                        appUi.addGenreList(category)
                    }
                    model: ListModel{
                        ListElement{
                            name: "Art & Design"
                        }
                        ListElement{
                            name: "Auto & Vehicles"
                        }
                        ListElement{
                            name: "Beauty"
                        }
                        ListElement{
                            name: "Books & Reference"
                        }
                        ListElement{
                            name: "Business"
                        }
                        ListElement{
                            name: "Comics"
                        }
                        ListElement{
                            name: "Communication"
                        }
                        ListElement{
                            name: "Dating"
                        }
                        ListElement{
                            name: "Education"
                        }
                        ListElement{
                            name: "Entertainment"
                        }
                        ListElement{
                            name: "Events"
                        }
                        ListElement{
                            name: "Family"
                        }
                        ListElement{
                            name: "Finance"
                        }
                        ListElement{
                            name: "Food & Drink"
                        }
                        ListElement{
                            name: "Health & Fitness"
                        }
                        ListElement{
                            name: "House & Home"
                        }
                        ListElement{
                            name: "Libraries & Demo"
                        }
                        ListElement{
                            name: "Lifestyle"
                        }
                        ListElement{
                            name: "Maps & Navigation"
                        }
                        ListElement{
                            name: "Medical"
                        }
                        ListElement{
                            name: "Music & Audio"
                        }
                        ListElement{
                            name: "News & Magazines"
                        }
                        ListElement{
                            name: "Parenting"
                        }
                        ListElement{
                            name: "Personalization"
                        }
                        ListElement{
                            name: "Photography"
                        }
                        ListElement{
                            name: "Productivity"
                        }
                        ListElement{
                            name: "Shopping"
                        }
                        ListElement{
                            name: "Social"
                        }
                        ListElement{
                            name: "Sports"
                        }
                        ListElement{
                            name: "Tools"
                        }
                        ListElement{
                            name: "Travel & Local"
                        }
                        ListElement{
                            name: "Video Players & Editors"
                        }
                        ListElement{
                            name: "Weather"
                        }
                    }
                }
                CategoryList{
                    id: gamesGenreList
                    onCategorySelected:{
                        appUi.addGenreList(category)
                    }

                    model: ListModel{
                        ListElement{
                            name: "Action"
                        }
                        ListElement{
                            name: "Adventure"
                        }
                        ListElement{
                            name: "Arcade"
                        }
                        ListElement{
                            name: "Board"
                        }
                        ListElement{
                            name: "Card"
                        }
                        ListElement{
                            name: "Casino"
                        }
                        ListElement{
                            name: "Educational"
                        }
                        ListElement{
                            name: "Music"
                        }
                        ListElement{
                            name: "Puzzle"
                        }
                        ListElement{
                            name: "Racing"
                        }
                        ListElement{
                            name: "Role Playing"
                        }
                        ListElement{
                            name: "Sports"
                        }
                        ListElement{
                            name: "Strategy"
                        }
                        ListElement{
                            name: "Trivia"
                        }
                        ListElement{
                            name: "Word"
                        }

                    }
                }//CategoryList

            }//SwipeView

            //bottom menu
            Button{
                id: exitButton
                width: parent.width
                text: "EXIT"
                Material.background: appTheme.accent
                onClicked: {
                    appUi.close();
                    //appUi.destroy();
                }
            }
        }
    }


    Page{
        id: appUiMainPage
        anchors.top: parent.top
        width: parent.width
        height: parent.height
        Material.accent: appTheme.accent
        Material.primary: appTheme.primary
        Material.background: appTheme.background
        Material.foreground: appTheme.foreground
        Material.theme: appTheme.theme==="dark"?Material.Dark:Material.Light

        SwipeView{
            clip: true
            id: appUiSwipeView
            interactive: false
            anchors.fill: parent
            currentIndex: 0
            property bool isErrorOccured: false
            Page{
                id: loadingPage

                Timer{
                    id: mainTimer
                    interval: 500
                    repeat: true
                    running: appUiSwipeView.currentIndex === 0 && !appUiSwipeView.isErrorOccured
                    triggeredOnStart: true
                    property int counter: 0
                    onTriggered: {
                        if(appUiSwipeView.currentIndex===0){
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
                Label{
                    id: loadingMessage
                    text: "Indexing"
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Label.AlignVCenter
                    horizontalAlignment: Label.AlignHCenter
                    maximumLineCount: 3
                }

                PageIndicator{
                    id: loadingProgress
                    count: 4
                    anchors.top: loadingMessage.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item{
                    anchors.top: loadingProgress.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: QbCoreOne.scale(50)
                    visible: appUiSwipeView.isErrorOccured
                    Row{
                        anchors.centerIn: parent
                        spacing: QbCoreOne.scale(10)
                        Button{
                            id: reloadButton
                            text: "RELOAD"
                            Material.background: appTheme.lighter(appTheme.accent,150)
                            onClicked: {
                                appUiSwipeView.currentIndex = 0;
                                appUiSwipeView.isErrorOccured = false;
                                loadingMessage.text = "Indexing";
                                mainTimer.start();
                                LUiController.startIndexing();
                            }
                        }
                        Button{
                            id: nextButton
                            text: "NEXT"
                            Material.background: appTheme.lighter(appTheme.accent,150)
                            onClicked: {
                                appUiSwipeView.currentIndex = 1;
                                LUiController.search("","");

                            }
                        }
                    }
                }
            }

            StackView{
                clip: true
                id: appStackView
                initialItem: AppListView{
                    id: appListView
                }
            }
        }
    }

    Component {
        id: appListViewComponent
        AppListView {
            id: appListViewNew
        }
    }
    Component{
        id: appViewComponent
        AppView{
            id: appView
        }
    }

    function pop(){
        if(appStackView.depth>1){
            appStackView.pop();
        }
    }

    function showLoadingScreen(){
        appUiSwipeView.currentIndex = 0;
        loadingMessage.text = "Indexing"
        appUiSwipeView.isErrorOccured = false;
    }

    function hideLoadingScreen(){
        appUiSwipeView.currentIndex = 1;
    }

    function showIndexError(){
        appUiSwipeView.currentIndex = 0;
        loadingMessage.text = "Failed to index. \nPlease make sure you have stable internet connection.\nHit reload to index again."
        appUiSwipeView.isErrorOccured = true;
    }

    function openMenuDrawer(){
        menuDrawer.open();
    }

    function addGenreList(genre){
        menuDrawer.close();
        var item = appListViewComponent.createObject(appStackView,{"genre":genre});
        appStackView.push(item);
        appStackView.currentItem.model = [];
        appStackView.currentItem.startLoadingProgress();
    }

    function showCurrentAppListViewLoadingScreen(){
        //console.log(String(appStackView.currentItem))
        if(String(appStackView.currentItem).indexOf("AppListView") === 0){
            appStackView.currentItem.startLoadingProgress();
        }
    }

    function addModelToCurrentAppListView(model){
        if(String(appStackView.currentItem).indexOf("AppListView") === 0){
            appStackView.currentItem.setModel(model);
        }
    }

    function addSingleAppView(name,namespace,version,repo){
        //console.log(namespace);
        var item = appViewComponent.createObject(appStackView,{"appName":name,"appVersion":version,"appNameSpace":namespace,"appRepo":repo});
        appStackView.push(item);
    }
}
