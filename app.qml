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
            Page{
                clip: true
                id: loadingPage
                Item{
                    width: 100
                    height: 100
                    anchors.centerIn: parent
                    //color: "black"
                    Text{
                        text: "Loading..."
                        color: appTheme.foreground
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

    function showLoadingScreen(){
        appUiSwipeView.currentIndex = 0;
    }

    function hideLoadingScreen(){
        appUiSwipeView.currentIndex = 1;
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
        appStackView.currentItem.startLoadingProgress();
    }

    function addModelToCurrentAppListView(model){
        appStackView.currentItem.setModel(model);
    }
}
