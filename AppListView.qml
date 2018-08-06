import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3

import Qb 1.0
import Qb.Core 1.0

import "ljs/qbapp.js" as LApp
import "ljs/uicontroller.js" as LUiController

Page {
    id: appListView
    property string genre: ""
    property string tag: ""
    property var model: []
    property bool isLoading: false;

    onGenreChanged: {
        startLoadingProgress();
        LUiController.search(genre,tag);
    }

    onTagChanged: {
        startLoadingProgress();
        LUiController.search(genre,tag);
    }

    ToolBar{
        id: topToolBar
        anchors.top: parent.top
        width: parent.width
        height: QbCoreOne.scale(50)
        Material.background: appTheme.primary
        Item{
            id: contentPlaceHolder
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height

            ToolButton{
                id: menuButton
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-menu")
                font.family: QbMF3.family
                anchors.left: parent.left
                onClicked: {
                    appUi.openMenuDrawer();
                }
            }

            ToolButton{
                id: backButton
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-home")
                font.family: QbMF3.family
                anchors.left: menuButton.right
                visible: appStackView.depth>1
                onClicked: {
                    while(appStackView.depth>1){
                        appStackView.pop();
                    }
                    //appListView.genre = "";
                    //appListView.tag = "";
                }
            }

            ToolButton{
                id: searchButton
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-search")
                font.family: QbMF3.family
                anchors.right: reloadButton.left
                onClicked: {
                    if(searchField.visible){
                        searchField.opacity = 0;
                    }
                    else{
                        //searchField.visible = true;
                        searchField.opacity = 1;
                        searchField.text = "";
                    }
                }
            }

            ToolButton{
                id: reloadButton
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-refresh")
                font.family: QbMF3.family
                anchors.right: showDownloadManagerButton.left
                onClicked: {
                    appListView.genre = "";
                    appListView.tag = "";
                    startLoadingProgress();
                    LUiController.search("","");
                }
            }

            ToolButton{
                id: showDownloadManagerButton
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-file_download")
                font.family: QbMF3.family
                anchors.right: parent.right
                onClicked: {
                    appDownloadManagerUi.open()
                }
            }

            Label{
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text: genre
                visible: !searchField.visible
                width: parent.width*0.50
                height: parent.height
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
                font.bold: true
            }

            TextField{
                anchors.top: parent.top
                //anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                visible: false
                anchors.left: backButton.visible?backButton.right:menuButton.right
                anchors.right: searchButton.left
                id: searchField
                inputMethodHints: Qt.ImhNoPredictiveText
                //width: parent.width*0.50
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                placeholderText: QbFA.icon("fa-search")+" Search Apps"
                font: QbFA.family

                onOpacityChanged: {
                    if(opacity === 0){
                        visible = false;
                    }
                    else{
                        visible = true;
                    }
                }

                onTextChanged: {
                    if(visible){
                        appListView.tag = searchField.text;
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

        }
    }

    Item{
        anchors.top: topToolBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        GridView{
            id: gridView
            clip: true
            anchors.top: parent.top
            anchors.topMargin: QbCoreOne.scale(20)
            cellHeight: QbCoreOne.scale(100)
            cellWidth: Qt.platform.os === "android"?gridView.width:QbCoreOne.scale(300)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: QbCoreOne.scale(10)
            anchors.right: parent.right
            anchors.rightMargin: QbCoreOne.scale(10)

            model:appListView.model
            visible: appListView.model.length!==0
            property int selectedIndex: -1;

            delegate: Item{
                id: singleGrid
                width: gridView.cellWidth*0.90
                height: gridView.cellHeight*0.90
                property color textColor: gridView.selectedIndex===index?appTheme.lighter(appTheme.accent,200): appTheme.foreground
                Rectangle{
                    //translucencySource: appBackground
                    anchors.fill: parent
                    color: "transparent"
                    //border.color: gridView.selectedIndex===index?appTheme.lighter(appTheme.secondary): appTheme.foreground
                    //border.width: QbCoreOne.scale(2)
                    //radius: QbCoreOne.scale(5)
                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            gridView.selectedIndex = index;
                        }
                        onDoubleClicked: {
                            gridView.selectedIndex = index;
                            appUi.addSingleAppView(String(appListView.model[index]["name"]),
                                                   String(appListView.model[index]["namespace"]),
                                                   String(appListView.model[index]["version"]),
                                                   String(appListView.model[index]["repo"])
                                                   )
                        }
                    }
                    //                    Rectangle{
                    //                        width: QbCoreOne.scale(2)
                    //                        height: parent.height
                    //                        border.color: gridView.selectedIndex===index?appTheme.lighter(appTheme.secondary): appTheme.foreground
                    //                    }

                    //itemRadious: 0
                    //backgroundColorOpacity: 0.6
                    Image{
                        id: appIconImage
                        anchors.left: parent.left
                        anchors.leftMargin: QbCoreOne.scale(5)
                        anchors.verticalCenter: parent.verticalCenter
                        width: QbCoreOne.scale(64)
                        smooth: true
                        mipmap: true
                        fillMode: Image.Image.PreserveAspectFit
                        height: QbCoreOne.scale(64)
                        source: "https://raw.githubusercontent.com/"+appListView.model[index]["repo"]+"/"+appListView.model[index]["version"]+"/app.png"
                    }

                    Item{
                        id: textPlaceHolder
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: appIconImage.right
                        anchors.leftMargin: QbCoreOne.scale(5)
                        anchors.right: parent.right
                        height: appIconImage.height
                        clip: true
                        Column{
                            anchors.fill: parent
                            Label{
                                text: String(appListView.model[index]["name"])
                                color: singleGrid.textColor
                                width: parent.width
                            }
                            Label{
                                text: String(appListView.model[index]["namespace"])
                                color: appTheme.darker(singleGrid.textColor,150)
                                width: parent.width
                                elide: Label.ElideMiddle
                            }
                            Label{
                                width: parent.width
                                text: String(appListView.model[index]["version"])
                                color: appTheme.darker(singleGrid.textColor,150)
                            }
                        }
                    }
                }
            }
        }

        Item{
            anchors.fill: parent
            visible: appListView.isLoading===true?false:appListView.model.length===0
            Label{
                anchors.fill: parent
                text: "No Apps Found"
                font.bold: true
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
            }
        }
    }

    function startLoadingProgress(){
        appListView.isLoading = true;
    }

    function stopLoadingProgress(){
        appListView.isLoading = false;
    }

    function setModel(m){
        appListView.model = m;
        appListView.isLoading = false;
    }
}
