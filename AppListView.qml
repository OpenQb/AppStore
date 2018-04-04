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

    onGenreChanged: {
        LUiController.search(genre,tag);
    }

    onTagChanged: {
        LUiController.search(genre,tag);
    }

    ToolBar{
        id: topToolBar
        anchors.top: parent.top
        width: parent.width
        height: QbCoreOne.scale(50)
        background: TranslucentGlass{
            translucencySource: appBackground
            backgroundColor: appTheme.background
            backgroundColorOpacity: 0.9
            itemRadious: 0//QbCoreOne.scale(10)
        }
        Item{
            id: contentPlaceHolder
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height

            ToolButton{
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
                width: QbCoreOne.scale(50)
                height: QbCoreOne.scale(50)
                text: QbMF3.icon("mf-search")
                font.family: QbMF3.family
                anchors.right: parent.right
                onClicked: {
                    //searchField.visible = true;
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

            TextField{
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0
                visible: false
                id: searchField
                width: parent.width*0.70
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
        anchors.bottom: parent.bottom
        ListView{
            anchors.top: parent.top
            anchors.topMargin: QbCoreOne.scale(20)

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            model:appListView.model

            delegate: Rectangle{
                color: "blue"
                Text{
                    text: String(appListView.model[index]["name"])
                    color: appTheme.foreground
                }
            }
        }
    }

    function startLoadingProgress(){

    }

    function stopLoadingProgress(){

    }

    function setModel(m){
        appListView.model = m;
    }
}
