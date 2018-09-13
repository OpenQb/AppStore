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

load("AppStoreDbApi.js");
var readySignalSent = false;
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
