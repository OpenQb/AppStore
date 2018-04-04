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
                }
            }

            SwipeView{
                id: menuDrawerSwipeView
                width: parent.width
                height: parent.height - menuDrawerTabBar.height
                currentIndex: menuDrawerTabBar.currentIndex
                interactive: false
                clip: true

                ListView{
                    clip: true
                    model: 10
                    delegate: Item{
                        width: parent.width
                        height: 100
                        Text{
                            text: index
                            anchors.fill: parent
                        }
                    }
                }

                ListView{
                    clip: true
                    model: 100
                    delegate: Item{
                        width: parent.width
                        height: 100
                        Text{
                            text: index
                            anchors.fill: parent
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
            id: appUiSwipeView
            interactive: false
            anchors.fill: parent
            currentIndex: 0
            Page{
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
                id: appStackView
                initialItem: AppListView{
                    id: appListView
                }
            }
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
}
