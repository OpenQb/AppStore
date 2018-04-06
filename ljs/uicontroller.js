.pragma library

.import "qbapp.js" as LApp

var fileObject;
var pathsObject;
var engineObject;
var appStackView;
var appListView;
var appUi;
var appDownloadManagerUi;
var appDownloadManagerModel;
var downloadList = [];
var ready = false;
var appStorage;
var qbCoreOne;

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

function download(name,ns,repo,version,uindex){
    sendObject({
                   "action":"download",
                   "namespace":ns,
                   "name":name,
                   "repo":repo,
                   "version":version,
                   "uindex":uindex
               });
}

function stop(ns){
    sendObject({
                   "action":"download:stop",
                   "namespace":ns
               });
}


function downloadApp(name,namespace,repo,version){
    appDownloadManagerModel.append(
                {
                    "name":name,
                    "namespace":namespace,
                    "repo":repo,
                    "version":version,
                    "isDownloading":true,
                    "msg":"",
                    "totalReceived": "O KB"
                }
                );

    download(name,namespace,repo,version,appDownloadManagerModel.count-1);
}

function isDownloading(namespace){
    return downloadList.indexOf(namespace) !==-1;
}

function cancelDownload(namespace){
    stop(namespace);
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

function findIndex(ns) {
    for(var i = 0; i < appDownloadManagerModel.count; ++i) if (appDownloadManagerModel.get(i)["namespace"] === ns) return i;
    return -1;
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
                       "dbpath":LApp.absoluteDatabasePath("AppStoreDb")
                   });

    }



    else if(json_data["action"] === "setup:complete"){
        startIndexing();
    }


    else if(json_data["action"] === "search:started"){
        console.log("Search started");
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
        //console.log(String(json_data["data"]).indexOf("Index failed"));
        if(String(json_data["data"]).indexOf("Index failed")===0 ){
            //console.log("got zero");
            appUi.showIndexError();
        }
        else{
            appUi.hideLoadingScreen();
            search("","");
        }
    }

    /*Interact with the DownloadManager UI*/
    else if(json_data["action"] === "download:started"){
        //console.log(data);
        //var index = json_data["uindex"];
        downloadList.push(json_data["namespace"]);

    }
    else if(json_data["action"] === "download:finished"){
        //console.log(data);
        try{
            i = downloadList.indexOf(json_data["namespace"]);
            if(i!==-1) delete downloadList[i];
            var saveAs = json_data["path"];
            //console.log(saveAs);
            index = json_data["uindex"];
            //console.log("Uindex: "+index);
            if(index!==-1){
                appDownloadManagerModel.set(index,{"isDownloading":false});
            }
            if(appStorage.installApp(saveAs)){
                qbCoreOne.reload();
            }
        }
        catch(e){
            console.log("Download finished with exception "+e);
        }
    }
    else if(json_data["action"] === "download:progress"){
        var ns = json_data["namespace"];
        var progress = json_data["progress"];
        var tr = parseFloat(progress/1024).toFixed(2) + " KB";
        index = json_data["uindex"];
        if(index!==-1){
            appDownloadManagerModel.set(index,{"totalReceived":tr});
        }

    }
    else if(json_data["action"] === "download:error"){
        console.log(data)
        var i = downloadList.indexOf(json_data["namespace"]);
        if(i!==-1) delete downloadList[i];
        var index = json_data["uindex"];
        if(index!==-1){
            appDownloadManagerModel.set(index,{"isDownloading":false});
        }
    }
    /*end*/



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
