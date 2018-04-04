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
    else if(json_data["action"] === "appList")
    {
        sendObject({"action":"appList:started"});
    }
    else if(json_data["action"] === "search"){
        sendObject({"action":"search:started"});
        dbApiObject.search(json_data["data"][0],json_data["data"][1]);
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
