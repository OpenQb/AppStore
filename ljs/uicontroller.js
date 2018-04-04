.pragma library

.import "qbapp.js" as LApp

var fileObject;
var pathsObject;
var engineObject;
var appStackView;
var appListView;
var appUi;

var ready = false;

function setup()
{
    /* Install all extensions */
    if(engineObject){
        engineObject.installQbExtensions();
    }
    /* Start X Engine*/
    startXEngine(LApp.absolutePath("/exjs/xengine.js"));
    ready = true;
}


function startXEngine(p)
{
    if(engineObject){
        engineObject.setPackageVariant(appUi.packageVariant());
        engineObject.setCodeFromFile(p);
        engineObject.start();
//        if(fileObject){
//            fileObject.setFileName(p);
//            var code;
//            if(fileObject.open("r")){
//                code = fileObject.readAll();
//                fileObject.close();
//            }
//            fileObject.setFileName("");
//            if(code){
//                engineObject.setCode("xengine",code);
//                engineObject.start();
//            }
//        }
    }
}

function sendObject(o){
    engineObject.sendMessage(JSON.stringify(o));
}

function appList(genre)
{
    sendObject({
                    "action": "appList",
                    "data" :[genre]
                });

}

function download(repo,version){
    sendObject({
                   "action":"downloadRepo",
                   "data":[repo,version]
               });
}

function search(genre,tag)
{
    sendObject({
                    "action": "search",
                    "data" :[genre,tag]
                });
}


function startIndexing()
{
    sendObject({
               "action" : "indexing"
               });
}

function readyXEngineResult(data)
{
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
                       "dbpath":LApp.absoluteDatabasePath("AppStoreDb")
                   });

    }



    else if(json_data["action"] === "setup:complete"){
        startIndexing();
    }


    else if(json_data["action"] === "search:started"){
        console.log("Search started");
        //appListView.setModel([]);
        //appListView.startLoadingProgress();
        appUi.showCurrentAppListViewLoadingScreen();
    }
    else if(json_data["action"] === "search:progress"){

    }
    else if(json_data["action"] === "search:finished"){
        //console.log(data);
        console.log("Search finished");
        appUi.addModelToCurrentAppListView(json_data["data"]);
        //appListView.setModel(json_data["data"]);
//        for(var i=0;i<json_data["data"].length;++i){
//            console.log(Object.keys(json_data["data"][i]));
//        }
//        /appListView.stopLoadingProgress();
    }



    else if(json_data["action"] === "indexing:started"){
        appUi.showLoadingScreen();
        console.log("indexing Started");
    }
    else if(json_data["action"] === "indexing:progress"){
        console.log(json_data["data"]);
    }
    else if(json_data["action"] === "indexing:finished"){
        console.log(json_data["data"]);
        appUi.hideLoadingScreen();
        search("","");
    }



    else if(json_data["action"] === "heartbeat"){
        console.log(json_data["data"]);
    }
    else{
        console.log(data)
    }
}

function isReady(){
    return ready;
}
