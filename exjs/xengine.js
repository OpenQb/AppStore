function sendObject(o){
    sendMessage(JSON.stringify(o));
};

function uniq_fast(a) {
    var seen = {};
    var out = [];
    var len = a.length;
    var j = 0;
    for(var i = 0; i < len; i++) {
        var item = a[i];
        if(seen[item] !== 1) {
            seen[item] = 1;
            out[j++] = item;
        }
    }
    return out;
}

load("AppStoreDbApi.js");


function SpecialDict(){
    var primary = [];
    var secondary = [];

    this.push = function(k,v){
        primary.push(k);
        secondary.push(v);
    }

    this.pop = function(){
        primary.pop();
        secondary.pop();
    }

    this.keyToValue = function(k){
        if(primary.length !== secondary.length) return;
        var i = primary.indexOf(k);
        return secondary[i];
    }

    this.valueToKey = function(v){
        if(primary.length !== secondary.length) return;
        var i = secondary.indexOf(v);
        return primary[i];
    }

    this.removeByKey = function(k){
        var i = primary.indexOf(k);
        try{
            delete primary[i];
            delete secondary[i];
        }
        catch(e){}
    }

    this.removeByValue = function(v){
        var i = secondary.indexOf(v);
        try{
            delete primary[i];
            delete secondary[i];
        }
        catch(e){
        }
    }
}


/*QbApp Downloadmanager*/
function QbDownloadManager(){

    var requestObject = include("QbCore::QbRequest");
    var pathObject = include("QbCore::QbPaths");

    var nsMap = {};
    var ridToNsMap = new SpecialDict();


    var sendDownloadStarted = function(ns,uindex){
        sendObject({"action":"download:started","namespace":ns,"uindex":uindex});

    };
    var sendDownloadFinished = function(ns,path,uindex){
        sendObject({"action":"download:finished","namespace":ns,"path":path,"uindex":uindex});
    };
    var sendDownloadProgress = function(ns,progress,total,uindex){
        sendObject({"action":"download:progress","namespace":ns,"progress":progress,"total":total,"uindex":uindex});
    };
    var sendDownloadError = function(ns,message,uindex){
        sendObject({"action":"download:error","namespace":ns,"message":message,"uindex":uindex});
    };

    var downloadUrl = function(repo,version){
        var u = "https://codeload.github.com/"+repo+"/legacy.zip/"+version;
        return u;
    };

    var resultReady = function(rid,result){
        var uindex = nsMap[rid];
        var ns = ridToNsMap.keyToValue(rid);
        var saveAs = pathObject.downloads()+"/"+ns+".zip";
        var jdata = JSON.parse(result);
        if(jdata["status_code"] === 200){
            sendDownloadFinished(ns,saveAs,uindex);
        }
        else{
            sendDownloadError(ns,"Error code:"+jdata["status_code"],uindex);
        }
        try{
            delete nsMap[rid];
        }
        catch(e){
        }
    };
    var downloadProgress = function(rid,bytesReceived,bytesTotal){
        //log("downloadProgress");
        //log(rid);
        //log(bytesReceived);
        //log(bytesTotal);
        var uindex = nsMap[rid];
        //log(uindex);
        var ns = ridToNsMap.keyToValue(rid);
        sendDownloadProgress(ns,bytesReceived,bytesTotal,uindex);
    };

    requestObject.onResultReady.connect(resultReady);
    requestObject.onDownloadProgress.connect(downloadProgress);


    this.download = function(ns,repo,version,uindex){
        //log("download");
        //log(uindex);
        var url = downloadUrl(repo,version);
        var saveAs = pathObject.downloads()+"/"+ns+".zip";
        //log(url);
        //log(saveAs);

        var args = {"saveAs":saveAs};
        var rmap = requestObject.get(url,args);
        var rid = rmap["rid"];

        nsMap[rid] = uindex;
        sendDownloadStarted(ns,uindex);
        //log("RID: "+rid);
        ridToNsMap.push(rid,ns);
    };

    this.stop = function(ns){
        var rid = ridToNsMap.valueToKey(ns);
        requestObject.stop(rid);
    };
};



var readySignalSent = false;
var dbApiObject = new AppStoreDbApi();
var counter = 30*2;
var downloadManager = new QbDownloadManager();

var _onMessageReceived = function(data)
{
    var json_data = JSON.parse(data);
    if(json_data["action"] === "setup")
    {
        dbApiObject.setup(json_data["dbpath"]);
        sendObject({"action":"setup:complete"});
    }
    else if(json_data["action"] === "appList")
    {
        sendObject({"action":"appList:started"});
    }
    else if(json_data["action"] === "search"){
        sendObject({"action":"search:started"});
        dbApiObject.search(json_data["data"][0],json_data["data"][1]);
    }


    else if(json_data["action"] === "download"){
        downloadManager.download(json_data["namespace"],json_data["repo"],json_data["version"],json_data["uindex"]);
    }
    else if(json_data["action"] === "download:cancel"){
        downloadManager.stop(json_data["namespace"]);
    }
    else if(json_data["action"] === "download:stop"){
        downloadManager.stop(json_data["namespace"]);
    }


    else if(json_data["action"] === "indexing"){
        dbApiObject.startIndexing();
    }
    else{
        sendObject({"action":"heartbeat","data":"Do not know what to do with it:"+data});
    }
};

onMessageReceived(_onMessageReceived);
sendMessage(JSON.stringify({"action":"ready"}));
sendObject({
               "action":"heartbeat",
               "data":"["+ new Date()+ "] XEngine is running."
           });
QbJSEngineObject.loop();
