/* QbRequest Class to make http call*/
function QbRequest(){
    this.__m_core_one = include("QbCore::QbCore");
    this.__m_requestObject = include("QbCore::QbRequest");

    var __m_request_track = {};
    var l_core_one = this.__m_core_one;

    var resultReady = function(rid,result){
        if(__m_request_track[rid]){
            var jdata = JSON.parse(result);
            __m_request_track[rid](l_core_one.fromBase64(jdata["data"]),jdata["status_code"],jdata["headers"]);
            delete __m_request_track[rid];
        }
    };

    this.get = function(url,args,callable)
    {
        var dmap = this.__m_requestObject.get(url,args);
        __m_request_track[dmap["rid"]] = callable;
    };

    this.toBase64 = function(data){
        return this.__m_core_one.toBase64(data);
    };

    this.fromBase64 = function(data){
        return this.__m_core_one.fromBase64(data);
    }

    this.isFinished = function(){
        return Object.keys(__m_request_track).length === 0;
    }

    this.__m_requestObject.onResultReady.connect(resultReady);
};
