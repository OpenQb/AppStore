import Qb 1.0
import QbEx 1.0
import ZeUi 1.0
import QbSql 1.0
import QtQuick 2.11


ZSOneAppPage{
    id: objHomePage
    title: "Home"
    activeFocusOnTab: false
    contextDock: objContextDock
    anchors.fill: parent

    QbSqlSM{
        id: objSqlSM
        tableStructure: {
            "KeyValuePair":"id INTEGER PRIMARY KEY,key VARCHAR(100) NOT NULL UNIQUE,value TEXT NOT NULL DEFAULT ''",
            "AppInfo":"id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,app TEXT,appimage TEXT",
            "Apps":"id INTEGER PRIMARY KEY,namespace VARCHAR(250) NOT NULL UNIQUE,repo VARCHAR(250) NOT NULL UNIQUE,version VARCHAR(30) NOT NULL",
            "TagList":"id INTEGER PRIMARY KEY,tag VARCHAR(100) NOT NULL UNIQUE",
            "TagRelation":"id INTEGER PRIMARY KEY,appid INTEGER DEFAULT 0,tagid INTEGER DEFAULT 0"
        }

        Component.onCompleted: {
            objSqlSM.setDatabase(ZBLib.appUi.absoluteDatabasePath("AppStoreDb"));
            objSqlSM.init();
        }

        //        dataTableSettings: {"TABLE":"TestTable","LIMIT":100,"ORDER_BY":"tid ASC","SEARCH_FIELD":"value"}

        //        Component.onCompleted: {
        //            objSSM.setDatabase(objPaths.documents()+"/MyTestDb.db");
        //            objSSM.init();
    }



    ListModel{
        id: objContextDock
        ListElement{
            icon: "mf-home"
            title: "Home"
        }
        ListElement{
            icon: "mf-refresh"
            title: "Refresh"
        }
        ListElement{
            icon: "mf-favorite_border"
            title: "Popular Downloads"
        }
        ListElement{
            icon: "mf-view_list"
            title: "Genres"
        }
        ListElement{
            icon: "mf-search"
            title: "Search"
        }
    }

    Rectangle{
        anchors.fill: parent
        color: "lightgrey"


    }
}
