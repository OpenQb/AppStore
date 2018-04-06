import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import Qb 1.0
import Qb.Core 1.0

import "ljs/qbapp.js" as LApp
import "ljs/uicontroller.js" as LUiController

QbApp {
    id: appUi

    QbMetaTheme{
        id: appTheme
    }

    QbAppStorage{
        id: appStorage
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
        topPadding: 0
        bottomPadding: 0
        rightPadding: 0
        leftPadding: 0
        background: TranslucentGlass{
            translucencySource: appBackground
            backgroundColorOpacity: 0.7
        }

        /***All Download Manager Methods will be here****/

    }


    Rectangle{
        id: statusBarPlaceHolder
        width: parent.width
        height: Qt.platform.os === "android"?0:0
        visible: true
        color: appTheme.background
    }

    Drawer {
        id: menuDrawer
        width: Math.min(0.66 * appListView.width,400)
        height: parent.height - statusBarPlaceHolder.height
        y: statusBarPlaceHolder.height
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
                height: parent.height - menuDrawerTabBar.height
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
                }
            }
        }
    }


    Page{
        id: appUiMainPage
        anchors.top: statusBarPlaceHolder.bottom
        width: parent.width
        height: parent.height - statusBarPlaceHolder.height
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
