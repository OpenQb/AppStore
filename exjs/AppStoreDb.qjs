function AppStoreDb()
{
    this.m_path = "";
    var sqlObject = include("QbSql::QbSql");

    this.setup = function(path){
        this.m_path = path;
        sqlObject.setDbPath(this.m_path);

        sqlObject.query("CREATE TABLE IF NOT EXISTS KeyValuePair(id INTEGER PRIMARY KEY,key VARCHAR(100) NOT NULL UNIQUE,value TEXT NOT NULL DEFAULT '');");
        sqlObject.query("CREATE TABLE IF NOT EXISTS AppInfo(id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,app TEXT,appimage TEXT);");
        sqlObject.query("CREATE TABLE IF NOT EXISTS Apps(id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,repo VARCHAR(250) NOT NULL UNIQUE,version VARCHAR(30) NOT NULL);");
        sqlObject.query("CREATE TABLE IF NOT EXISTS TagList(id INTEGER PRIMARY KEY,tag VARCHAR(100) NOT NULL UNIQUE);");
        sqlObject.query("CREATE TABLE IF NOT EXISTS TagRelation(id INTEGER PRIMARY KEY,appid INTEGER DEFAULT 0,tagid INTEGER DEFAULT 0);");

        sendObject({
                       "action" : "heartbeat",
                       "data" : "QbSql setup complete: "+path
                   });
    };


    this.addTag = function(tag){
        var r1 = sqlObject.preparedQuery("SELECT * FROM TagList WHERE tag=:tag;",[{"name":":tag","data":tag}]);
        if(r1["status"] === "OK"){
            if(r1["data"].length === 1){
                return r1["data"][0]["id"];
            }
            else{
                var r = sqlObject.preparedQuery("INSERT INTO TagList(tag) values(:tag);",[{"name":":tag","data":tag}]);
                if(r["status"] === "OK"){
                    return r["liid"];
                }
                else{
                    return -1;
                }
            }
        }
    };


    this.getAppId = function(namespace){
        var q2 = ["SELECT * FROM Apps WHERE namespace=:namespace",
                  [
                      {"name":":namespace","data":namespace}
                  ]
                ];
        var r = sqlObject.preparedQuery(q2[0],q2[1]);
        if(r["status"] === "OK"){
            if(r["data"].length === 1){
                return r["data"][0]["id"];
            }
        }
        return -1;
    };

    this.getAppById = function(uid){
        var q2 = ["SELECT * FROM Apps WHERE id=:uid;",
                  [
                      {"name":":uid","data":uid,"type":"integer"}
                  ]
                ];
        var r = sqlObject.preparedQuery(q2[0],q2[1]);
        if(r["status"] === "OK"){
            //log("G:"+r["data"][0]["namespace"]);
            if(r["data"].length === 1){
                return r["data"][0];
            }
        }
        return -1;
    };

    this.addApp = function(category,genre,namespace,repo,version)
    {
        var q1 = ["INSERT INTO Apps(namespace,repo,version) VALUES(:namespace,:repo,:version);",
                  [
                      {"name":":namespace","data":namespace},
                      {"name":":repo","data":repo},
                      {"name":":version","data":version}
                  ]
                ];
        var q2 = ["UPDATE Apps SET repo=:repo,version=:version WHERE namespace=:namespace;",[
                      {"name":":namespace","data":namespace},
                      {"name":":repo","data":repo},
                      {"name":":version","data":version}
                  ]];
        var r;
        var tid;

        var appId = this.getAppId(namespace);
        if(appId === -1){
            //insert mode
            r = sqlObject.preparedQuery(q1[0],q1[1]);
            if(r["status"] === "OK"){
                appId = r["liid"];

                tid = this.addTag(category);
                if(tid !== -1){
                    this.addTagReference(appId,tid);
                }

                tid = this.addTag(genre);
                if(tid !== -1){
                    this.addTagReference(appId,tid);
                }

                tid = this.addTag(namespace);
                if(tid !== -1){
                    this.addTagReference(appId,tid);
                }

                tid = this.addTag(repo);
                if(tid !== -1){
                    this.addTagReference(appId,tid);
                }
            }
        }
        else{
            //update mode
            r = sqlObject.preparedQuery(q2[0],q2[1]);

            this.removeTagReference(appId);
            tid = this.addTag(category);
            if(tid !== -1){
                this.addTagReference(appId,tid);
            }

            tid = this.addTag(genre);
            if(tid !== -1){
                this.addTagReference(appId,tid);
            }

            tid = this.addTag(namespace);
            if(tid !== -1){
                this.addTagReference(appId,tid);
            }

            tid = this.addTag(repo);
            if(tid !== -1){
                this.addTagReference(appId,tid);
            }

        }
    };

    this.removeApp = function(namespace){
        var appId = this.getAppId(namespace);
        if(appId === -1){
            this.removeTagReference(appId);
            var r = sqlObject.preparedQuery("DELETE FROM Apps WHERE namespace=:namespace",[
                                                {"name":":namespace","data":namespace}
                                            ]
                                            );
            return r["status"] === "OK";
        }

        return false;
    };

    this.addTagReference = function(appid,tagid){
        var r = sqlObject.preparedQuery("INSERT INTO TagRelation(appid,tagid) VALUES(:appid,:tagid);",[{"name":":appid","data":appid},{"name":":tagid","data":tagid}]);
        return r["status"] === "OK";
    };

    this.removeTagReference = function(appid){
        var r = sqlObject.preparedQuery("DELETE FROM TagRelation WHERE appid=:appid",[
                                            {"name":":appid","data":appid}
                                        ]
                                        );
        return r["status"] === "OK";
    }


    this.addKeyValue = function(key,value){
        var r = sqlObject.preparedQuery("INSERT INTO KeyValuePair(key,value) values(:key,:value);",[{"name":":key","data":key},{"name":":value","data":value}]);
        if(r["status"] === "OK"){
            return r["liid"];
        }
        else{
            return -1;
        }
    };

    this.isKeyExist = function(key){
        var r1 = sqlObject.preparedQuery("SELECT * FROM KeyValuePair WHERE key=:key;",[{"name":":key","data":key}]);
        if(r1["status"] === "OK"){
            if(r1["data"].length === 1){
                return true;
            }
        }

        return false;
    };

    this.getValue = function(key){
        var r1 = sqlObject.preparedQuery("SELECT * FROM KeyValuePair WHERE key=:key;",[{"name":":key","data":key}]);
        if(r1["status"] === "OK"){
            if(r1["data"].length === 1){
                return r1["data"][0]["value"];
            }
        }
        return "";
    };

    this.updateKeyValue = function(key,value){
        var r = sqlObject.preparedQuery("UPDATE KeyValuePair SET value=:value WHERE key=:key;",[{"name":":key","data":key},{"name":":value","data":value}]);
        if(r["status"] === "OK"){
            return true;
        }

        return false;
    };

    this.search = function(genre,tag){
        var data = [];
        var r1 = sqlObject.preparedQuery(
                    "SELECT * FROM TagList WHERE tag LIKE :genre AND tag LIKE :tag",
                    [
                        {"name":":genre","data":"%"+genre+"%"},
                        {"name":":tag","data":"%"+tag+"%"}
                    ]
                    );
        var appIdList = [];
        if(r1["status"] === "OK"){
            for(var i=0;i<r1["data"].length;++i){
                //log(r1["data"][i]["id"]);
                var r2 = sqlObject.preparedQuery(
                            "SELECT DISTINCT appid FROM TagRelation WHERE tagid LIKE :tagid;",
                            [
                                {"name":":tagid","data":r1["data"][i]["id"]}
                            ]
                            );
                if(r2["status"] === "OK"){
                    //log(r2["data"].length);
                    for(var i1=0;i1<r2["data"].length;++i1){
                        var appId = parseInt(r2["data"][i1]["appid"]);
                        if(appIdList.indexOf(appId) === -1){
                            //log(appIdList.indexOf(appId));
                            appIdList.push(appId);
                        }
                    }
                }
            }
        }

        //var uappIdList = uniq_fast(appIdList);
        //log("SD:"+appIdList.length);

        for(var i2=0;i2<appIdList.length;++i2){
            var dmap = this.getAppById(appIdList[i2]);
            if( dmap !== -1){
                dmap["namespace"] = String(dmap["namespace"]);
                var dl = String(dmap["repo"]).split("/");
                dmap["name"] = dl[dl.length-1];
                dmap["repo"] = String(dmap["repo"]);
                dmap["version"] = String(dmap["version"]);
                data.push(dmap);
            }
        }
        return data;
    };

};
