import QbEx 1.0
import QbSql 1.0
import Qb.Net 1.0
import Qb.Core 1.0
import QtQuick 2.11

import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

QbApp{
    id: objMainAppUi
    changeWindowPosition: true
    minimumHeight: 550
    minimumWidth: 500
    property string customSQ: "SELECT TagRelation.appid,Apps.namespace,Apps.repo,Apps.version FROM TagList,TagRelation,Apps WHERE TagRelation.tagid LIKE TagList.id AND TagRelation.appid LIKE Apps.id AND TagList.tag LIKE '%%' GROUP BY appid";

    QbSettings{
        id: objSettings
        name: "AppStore"
        property alias windowWidth: objMainAppUi.windowWidth
        property alias windowHeight: objMainAppUi.windowHeight
        property alias windowX: objMainAppUi.windowX
        property alias windowY: objMainAppUi.windowY
    }

    QbSqlSM{
        id: objSqlSM
        tableStructure: {
            "KeyValuePair":"id INTEGER PRIMARY KEY,key VARCHAR(100) NOT NULL UNIQUE,value TEXT NOT NULL DEFAULT ''",
                    "AppInfo":"id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,app TEXT,appimage TEXT",
                    "Apps":"id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,repo VARCHAR(250) NOT NULL UNIQUE,version VARCHAR(30) NOT NULL",
                    "TagList":"id INTEGER PRIMARY KEY,tag VARCHAR(100) NOT NULL UNIQUE",
                    "TagRelation":"id INTEGER PRIMARY KEY,appid INTEGER DEFAULT 0,tagid INTEGER DEFAULT 0"
        };
        customSearchQuery: objMainAppUi.customSQ;
        customRoles: ["APPID","NAMESPACE","REPO","VERSION"]
        onTotalPage: {
            if(totalPage === 0){
                objCVContentView.currentIndex = 1;
            }
            else{
                objCVContentView.currentIndex = 0;
            }
        }

        Component.onCompleted: {
            objSqlSM.setDatabase(objMainAppUi.absoluteDatabasePath("AppStoreDb"));
            objSqlSM.init();
        }
    }

    function search(tag){
        if(tag === undefined || tag === null || tag === ""){
            objSqlSM.customSearchQuery = objMainAppUi.customSQ;
            objSqlSM.search("");
        }
        else{
            objSqlSM.customSearchQuery = objMainAppUi.customSQ.replace("%%","%"+tag+"%");
            objSqlSM.search("");
        }
    }

    function dataURL(repo,version,file){
        return "https://raw.githubusercontent.com/"+repo+"/"+version+"/"+file;
    }


    QbAppStorage{
        id: objAppStorage
    }

    QbDM{
        id: objQbDM
    }

    QbQJSEngine{
        id: objQEngine
        onMessage: {
            readyXEngineResult(data);
        }
    }

    function sendObject(o){
        objQEngine.sendMessage(JSON.stringify(o));
    }

    function readyXEngineResult(data)
    {
        var i;
        var index;
        var json_data = {};
        try{
            json_data = JSON.parse(data);
        }
        catch(e){
            console.log("Exception occured:"+e);
            json_data["action"] = "";
        }

        if(json_data["action"]==="ready"){
            //XEngine is ready so send a command to do the task
            //console.log(LApp.absoluteDatabasePath("AppStoreDb"));
            sendObject({
                           "action":"setup",
                           "dbpath":objMainAppUi.absoluteDatabasePath("AppStoreDb")
                       });

        }

        else if(json_data["action"] === "setup:complete"){
            sendObject({
                           "action" : "indexing"
                       });
        }
        else if(json_data["action"] === "indexing:started"){
            console.log("indexing Started");
            objMainView.currentIndex = 0;
        }
        else if(json_data["action"] === "indexing:progress"){
            console.log(json_data["data"]);
        }
        else if(json_data["action"] === "indexing:finished"){
            //console.log(String(json_data["data"]).indexOf("Index failed"));
            if(String(json_data["data"]).indexOf("Index failed")===0 ){
                console.log("got zero");
                objMainView.currentIndex = 2;
            }
            else{
                console.log("indexing finished");
                objMainAppUi.search("");
                objMainView.currentIndex = 1;
            }
        }


        else if(json_data["action"] === "heartbeat"){
            console.log(json_data["data"]);
        }
        else{
            console.log(data)
        }
    }
    Component.onCompleted: {
        objQEngine.installQbExtensions();
        objQEngine.setPackageVariant(objMainAppUi.packageVariant());
        objQEngine.setCodeFromFile(objMainAppUi.absolutePath("/exjs/xengine.js"));
        objQEngine.start();
    }

    /*********** UI ******************/
    SwipeView{
        id: objMainView
        interactive: false
        anchors.fill: parent
        currentIndex: 0
        orientation: Qt.Vertical
        clip: true

        //Loading screen /0
        Rectangle{
            color: "black"
            //            Rectangle{
            //                anchors.centerIn: parent
            //                width: QbCoreOne.scale(60)
            //                height: QbCoreOne.scale(60)
            //                radius: width/2.0
            //                color: "transparent"
            //                border.width: 5
            //                border.color: "#00509B"
            FishSpinner {
                id: objSpin
                color: "#006ACE"
                radius: QbCoreOne.scale(22)
                useDouble: true
                anchors.centerIn: parent
            }
            //}
        }

        //ContentMainView /1
        Rectangle{
            id: objContentView
            color: "lightgrey"
            Item{
                id: objCVTopBlock
                anchors.top: parent.top
                width: parent.width
                height: Qt.platform.os === "android" || Qt.platform.os === "ios"?QbCoreOne.scale(80):QbCoreOne.scale(5)
            }

            //SearchBar
            Rectangle{
                id: objCVSearchBar
                anchors.top: objCVTopBlock.bottom
                width: parent.width*0.80
                height: QbCoreOne.scale(50)
                color: QbCoreOne.changeTransparency("black",180)
                radius: QbCoreOne.scale(5)
                x: (parent.width - width)/2.0

                Text{
                    id: objSearchIcon
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: QbCoreOne.scale(50)
                    height: parent.height
                    text: QbCoreOne.icon_font_text_code("mf-search")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.family: QbCoreOne.icon_font_name("mf-search")
                    font.pixelSize: parent.height*0.60
                    color: "white"
                }

                TextInput {
                    id: objSearchField
                    anchors.left: objSearchIcon.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: "Ubuntu"
                    font.pixelSize: 20
                    font.bold: true
                    activeFocusOnPress: true
                    activeFocusOnTab: true
                    selectionColor: "lightblue"
                    selectedTextColor: "black"
                    color: "white"
                    onTextChanged: {
                        objMainAppUi.search(objSearchField.text);
                    }
                }

            }//End SearchBar

            //Content Area
            Item{
                anchors.top: objCVSearchBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: objCVBottomBar.top

                SwipeView{
                    id: objCVContentView
                    interactive: false
                    orientation: Qt.Vertical
                    currentIndex: 0
                    clip: true
                    anchors.fill: parent

                    //SearchContent will go there
                    GridView{
                        id: objCVContentGrid
                        cellWidth: parent.width
                        cellHeight: QbCoreOne.scale(100)
                        model: objSqlSM
                        delegate: Item{
                            width: objCVContentGrid.cellWidth
                            height: objCVContentGrid.cellHeight
                            property string _name: String(REPO).split("/")[1]
                            property string _first: String(_name).charAt(0)
                            property string _repo: String(REPO)
                            property string _version: String(VERSION)
                            property string _namespace: String(NAMESPACE)

                            Rectangle{
                                color: "transparent"
                                border.width: 3
                                border.color: "grey"
                                radius: 5
                                anchors.centerIn: parent
                                width: parent.width*0.90
                                height: parent.height*0.90

                                Image{
                                    id: _objAppImage
                                    anchors.left: parent.left
                                    anchors.leftMargin: QbCoreOne.scale(5)

                                    anchors.top: parent.top
                                    anchors.topMargin: QbCoreOne.scale(5)

                                    width: objCVContentGrid.cellHeight *0.80
                                    height: width

                                    sourceSize.width: width
                                    sourceSize.height: width
                                    mipmap: true
                                    smooth: true
                                    fillMode: Image.PreserveAspectFit
                                    source:  images[_objAppImage.imageNo] //objMainAppUi.dataURL(_repo,_version,"app.svg")
                                    property int imageNo: 0
                                    property var images: [objMainAppUi.dataURL(_repo,_version,"app.svg"),objMainAppUi.dataURL(_repo,_version,"app.png"),"image://qbcore/"+_first]
                                    onStatusChanged: {
                                        if(_objAppImage.status == Image.Error){
                                            if(imageNo<3){
                                                ++_objAppImage.imageNo;
                                                _objAppImage.source = _objAppImage.images[_objAppImage.imageNo];
                                            }
                                        }
                                    }
                                }

                                Item{
                                    id: _objTextBlock
                                    anchors.top: parent.top
                                    anchors.topMargin: QbCoreOne.scale(5)
                                    anchors.left: _objAppImage.right
                                    anchors.leftMargin: QbCoreOne.scale(5)
                                    anchors.bottom: parent.bottom
                                    Text{
                                        anchors.fill: parent
                                        text: "<b>"+_name+"</b><br/>"+_namespace+"<br/>"+_version
                                        color: "black"
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }
                            }
                        }
                    }

                    Rectangle{
                        color: "lightgrey"
                        TextInput{
                            anchors.fill: parent
                            anchors.centerIn: parent
                            color: "grey"
                            text: "Nothing found."
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 25
                            wrapMode: TextInput.WordWrap
                            readOnly: true
                        }
                    }
                }
            }//End of content area

            Rectangle{
                id: objCVBottomBar
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: QbCoreOne.scale(50)
                color: QbCoreOne.changeTransparency("black",180)
            }
        }

        //ErrorView /2
        Rectangle{
            color: "lightgrey"

            TextInput{
                anchors.fill: parent
                anchors.centerIn: parent
                color: "grey"
                text: "Indexing failed. Error occured during indexing."
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 25
                wrapMode: TextInput.WordWrap
                readOnly: true
            }

            Button{
                x: (parent.width -  width)/2.0
                anchors.bottom: parent.bottom
                text: "CLOSE"
                Material.background: Material.Red
                Material.theme: Material.Light
                onClicked: {
                    objMainView.currentIndex = 1;
                }
            }
        }

    }
}
