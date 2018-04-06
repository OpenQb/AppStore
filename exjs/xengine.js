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
        var i = primary.indexOf(k);
        return secondary[i];
    }

    this.valueToKey = function(v){
        var i = secondary.indexOf(v);
        return primary[i];
    }

    this.removeByKey = function(k){
        var i = primary.indexOf(k);
        delete primary[i];
        delete secondary[i];
    }
    this.removeByValue = function(v){
        var i = secondary.indexOf(v);
        delete primary[i];
        delete secondary[i];
    }
}


/*QbApp Downloadmanager*/
function QbDownloadManager(){

    var requestObject = include("QbCore::QbRequest");
    var pathObject = include("QbCore::QbPaths");

    var nsMap = {};
    var ridToNsMap = new SpecialDict();


    var sendDownloadStarted = function(ns){
        sendObject({"action":"download:started","namespace":ns});

    };
    var sendDownloadFinished = function(ns,path){
        sendObject({"action":"download:finished","namespace":ns,"path":path});
    };
    var sendDownloadProgress = function(ns,progress){
        sendObject({"action":"download:progress","namespace":ns,"progress":progress});
    };
    var sendDownloadError = function(ns,message){
        sendObject({"action":"download:error","namespace":ns,"message":message});
    };


    var resultReady = function(rid,result){
    };
    var downloadProgress = function(rid,bytesReceived,bytesTotal){

    };
    var error = function(error){

    };


    this.download = function(ns,repo,version){

    }

    this.stop = function(ns){

    }
}



var readySignalSent = false;
var downloadManager = new QbDownloadManager();
var dbApiObject = new AppStoreDbApi();
var counter = 30*2;

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
        downloadManager.download(json_data["namespace"],json_data["repo"],json_data["version"]);
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

while(loopable()){

    if(!readySignalSent){
        sendMessage(JSON.stringify({"action":"ready"}));
        readySignalSent = true;
    }

    sleep(500);
    dbApiObject.heartbeat();

    if(counter === 30*2){
        sendObject({
                       "action":"heartbeat",
                       "data":"["+ new Date()+ "] XEngine is running."
                   });

        counter = 0;
    }
    counter = counter+1;
}
