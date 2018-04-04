load("QbRequest.js");
load("AppStoreDb.js");

/* AppStoreDbApi class to Work with GitHubApi */
function AppStoreDbApi()
{
    var m_apiRootUrl = "https://api.github.com";
    var githubUrl = "https://github.com";

    var firstCommitHash = "f61d2ae7eb9206ff248bf5dbd49382f6b4fab418";
    var requestObject = new QbRequest();
    var dbObject = new AppStoreDb();
    var soup = include("QbSoup::QbSoup");

    var action = "";

    var failedTxtFile = [];
    var crawlTxtFile = [];

    this.setup = function(path){
        dbObject.setup(path);
    }

    var sendIndexingProgress =  function(msg){
        sendObject({
                       "action" : "indexing:progress",
                       "data" : msg
                   });
    };

    var getCompareURL = function(base,head){
        return m_apiRootUrl+"/repos/OpenQb/AppStoreDb/compare/"+base+"..."+head;
    };

    var getTotalCommitURL = function(head){
        return m_apiRootUrl+"/repos/OpenQb/AppStoreDb/compare/"+firstCommitHash+"..."+head;
    };

    var getLastCommitHashURL = function(){
        return m_apiRootUrl+"/repos/OpenQb/AppStoreDb/git/refs/heads/master";
    };

    var getAppURL = function(name,version){
        return m_apiRootUrl+"/repos/"+name+"/releases/tags/"+version;
    };

    var getSingleCommitURL = function(hash){
        return m_apiRootUrl+"/repos/OpenQb/AppStoreDb/commits/"+hash;
    };

    var tagHTMLUrl = function(repo,version){
        return githubUrl+"/"+repo+"/"+"releases/tag/"+version;
    };

    var rawUrl = function(repo,version,file){
        return "https://raw.githubusercontent.com/"+repo+"/"+version+"/"+file;
    };

    var htmlCommitUrlToApiCommitUrl = function(url){
        var u1 = url.replace("commit","commits");
        return m_apiRootUrl+u1;
    }


    var getTxtFile = function(fname,url){
        var fileName = fname;
        if(fileName.indexOf("Games") === 0 || fileName.indexOf("Applications") === 0){
            sendIndexingProgress("Downloading {"+fileName+"}");

            requestObject.get(url,{"allow_redirects":true},function(data,status_code,headers){
                if(status_code === 200){
                    var ndata = String(data);
                    var dlist = ndata.split("\n");
                    var git = dlist[1];
                    var version = dlist[0];
                    sendIndexingProgress("Downloaded {"+fileName+"}");
                }
                else{
                    sendIndexingProgress("Download {"+fileName+"} failed");
                    failedTxtFile.append([fileName,url]);
                }
            });
        }
    }

    this.heartbeat = function()
    {

    }

    var parseFileName = function(name)
    {
        var fnList = String(name).split("/");

        var category = fnList[0];
        var genre = fnList[1];
        var namespace = String(fnList[2]).replace(".txt","");

        return [category,genre,namespace];
    }



    var lastHashToLatest = function(){
        var lastHash = String(dbObject.getValue("LAST_HASH"));
        var urlLatestCommitHash = getLastCommitHashURL();

        requestObject.get(urlLatestCommitHash,{},function(data,status_code,headers){
            if(status_code === 200){
                try{
                    var jd = JSON.parse(data);
                    var latestHash =  String(jd["object"]["sha"]);
                    //log(lastHash);
                    //log(latestHash);
                    //log(latestHash === lastHash);
                    if(lastHash === latestHash){
                        sendObject({
                                       "action": "indexing:finished",
                                       "data" : "Indexing successful."
                                   });
                    }
                    else{
                        var urlHashCompare;
                        urlHashCompare = getCompareURL(lastHash,latestHash);
                        sendIndexingProgress("Hash {"+latestHash+"} collecting.");
                        requestObject.get(urlHashCompare,{},function(data,status_code,headers){
                            if(status_code === 200){

                                try{
                                    var jd = JSON.parse(data);
                                    var fileList = [];

                                    for(var i=0; i< jd["files"].length; ++i){
                                        var fObject = jd["files"][i];
                                        if(fObject["status"] === "added" || fObject["status"] === "modified"){
                                            if(fObject["filename"].indexOf("Games") === 0 || fObject["filename"].indexOf("Applications") === 0){
                                                fileList.push([fObject["filename"],fObject["raw_url"]]);
                                            }
                                        }
                                        else{
                                            //deleted so delete all things from db related to namespace
                                            if(fObject["filename"].indexOf("Games") === 0 || fObject["filename"].indexOf("Applications") === 0){
                                                var namespace = parseFileName(fObject["filename"])[2];
                                                dbObject.removeApp(namespace);
                                            }
                                        }
                                    }

                                    var downloading = false;
                                    while(fileList.length !== 0)
                                    {
                                        if(!downloading){
                                            downloading = true;
                                            var fd = fileList[0];
                                            sendIndexingProgress("Downloading {"+fd[0]+"}");
                                            requestObject.get(fd[1],
                                                              {"allow_redirects":true},
                                                              function(data,status_code,headers){

                                                                  if(status_code === 200){
                                                                      var ndata = String(data);
                                                                      var dlist = ndata.split("\n");

                                                                      var fnList = String(fd[0]).split("/");

                                                                      var category = fnList[0];
                                                                      var genre = fnList[1];
                                                                      var namespace = String(fnList[2]).replace(".txt","");
                                                                      var repo = dlist[1];
                                                                      var version = dlist[0];

                                                                      dbObject.addApp(category,genre,namespace,repo,version);

                                                                      sendIndexingProgress("Downloaded {"+fd[0]+"}");
                                                                      fileList.splice(0,1);
                                                                  }
                                                                  else{

                                                                  }
                                                                  downloading = false;
                                                              });
                                        }

                                        pe();
                                    }
                                    sendIndexingProgress("Hash {"+latestHash+"} collected.");

                                    var r = dbObject.updateKeyValue("LAST_HASH",latestHash);
                                    sendObject({
                                                   "action": "indexing:finished",
                                                   "data" : "Indexing successful."
                                               });
                                }
                                catch(e){
                                    //need to start reindex
                                    sendObject({
                                                   "action" : "indexing:finished",
                                                   "data" : "Index failed. Hit refresh to index again. MSG:"+e
                                               });
                                }


                            }
                        });
                    }
                }
                catch(e){
                    sendObject({
                                   "action" : "indexing:finished",
                                   "data" : "Index failed. Hit refresh to index again. MSG:"+e
                               });
                }
            }
            else{
                //need to start reindex
                sendObject({
                               "action" : "indexing:finished",
                               "data" : "Index failed. Hit refresh to index again."
                           });
            }
        });
    };

    var startFromFirstCommit = function(){
        var url = getSingleCommitURL(firstCommitHash);

        requestObject.get(url,{},function(data,status_code,headers){
            if(status_code === 200){
                sendIndexingProgress("Hash {"+firstCommitHash+"} collected");
                //sendMessage(data);
                try{
                    var jd = JSON.parse(data);
                    var fileList = [];

                    for(var i=0; i< jd["files"].length; ++i){
                        var fObject = jd["files"][i];
                        if(fObject["status"] === "added" || fObject["status"] === "modified"){
                            if(fObject["filename"].indexOf("Games") === 0 || fObject["filename"].indexOf("Applications") === 0){
                                fileList.push([fObject["filename"],fObject["raw_url"]]);
                            }
                        }
                        else{
                            //deleted so delete all things from db related to namespace
                            if(fObject["filename"].indexOf("Games") === 0 || fObject["filename"].indexOf("Applications") === 0){
                                var namespace = parseFileName(fObject["filename"])[2];
                                dbObject.removeApp(namespace);
                            }
                        }
                    }

                    var downloading = false;
                    //fileList.reverse();
                    while(fileList.length !== 0)
                    {
                        if(!downloading){
                            downloading = true;
                            var fd = fileList[0];
                            sendIndexingProgress("Downloading {"+fd[0]+"}");
                            requestObject.get(fd[1],
                                              {"allow_redirects":true},
                                              function(data,status_code,headers){

                                                  if(status_code === 200){
                                                      var ndata = String(data);
                                                      var dlist = ndata.split("\n");

                                                      var fnList = String(fd[0]).split("/");

                                                      var category = fnList[0];
                                                      var genre = fnList[1];
                                                      var namespace = String(fnList[2]).replace(".txt","");
                                                      var repo = dlist[1];
                                                      var version = dlist[0];

                                                      dbObject.addApp(category,genre,namespace,repo,version);

                                                      sendIndexingProgress("Downloaded {"+fd[0]+"}");
                                                      fileList.splice(0,1);
                                                  }
                                                  else{

                                                  }
                                                  downloading = false;
                                              });
                        }

                        pe();
                    }

                    var r = dbObject.addKeyValue("LAST_HASH",firstCommitHash);
                    lastHashToLatest();
                }
                catch(e){
                    //need to start reindex
                    sendObject({
                                   "action" : "indexing:finished",
                                   "data" : "Index failed. Hit refresh to index again."
                               });
                }

            }
        });
    };

    this.get = function(url,callable){
        requestObject.get(url,{},callable);
    };


    this.startIndexing = function(){
        action = "indexing";
        sendObject({"action":"indexing:started"});
        if(dbObject.isKeyExist("LAST_HASH"))
        {
            /* so last hash already exists
            we just need to compare and grab changed result*/
            log("Collecting from lastHash");
            lastHashToLatest();

        }
        else{
            log("Collecting from the very beginning");
            /* No hash exists so lets grab from the beggining*/
            startFromFirstCommit();
        }
    };

    this.getData = function(data){
        var ndata = [];

        var downloading1 = false;
        //log("entering loop");
        while(data.length !== 0)
        {
            if(!downloading1){
                downloading1 = true;
                requestObject.get(rawUrl(data[0]["repo"],data[0]["version"],"app.json"),{},function(rdata,status_code,headers){
                    //log("Inside get");
                    if(status_code === 200){
                        //log(rdata);
                        try{
                            var jdata = JSON.parse(rdata);
                            jdata["icons"] = {"PNG":rawUrl(data[0]["repo"],data[0]["version"],"app.png"),"SVG":rawUrl(data[0]["repo"],data[0]["version"],"app.svg")};
                            jdata["AppStoreDb"] = {
                                "repo" : data[0]["repo"],
                                "version" : data[0]["version"]
                            };
                            ndata.push(jdata);
                        }
                        catch(e){
                            log(e);
                        }

                        //soup.reset(data);
                        //var div1 = soup.find("div","class","release-meta");

                        //soup.reset(div1.html());
                        //var aList = soup.findAll("a","","");
                        //var commit_url = aList.at(2).get("href");
                        //soup.clean();

                        //log(htmlCommitUrlToApiCommitUrl(commit_url));

                        downloading1 = false;
                        data.splice(0,1);
                    }
                    else{
                        downloading1 = false;
                    }

                });
            }

            pe();
        }
        return ndata;
    }

    this.search = function(genre,tag){
        var data = dbObject.search(genre,tag);
        //log("S:"+ndata[0]["namespace"]);
        //log(JSON.stringify({"action":"search:finished","data":data}));
        sendObject({"action":"search:finished","data":data});
    };

};
