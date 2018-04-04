.pragma library

var gApp;

function setup(_app) {
    gApp = _app;
}

function isReady(){
    if(gApp) return true;
    else return false;
}

function hide(){
    gApp.hide();
}

function close(){
    gApp.close();
}

function appTitle(){
    return gApp.appTitle;
}

function appNamespace(){
    return gApp.appNamespace;
}

function absolutePath(path){
    return gApp.absolutePath(path);
}
function absoluteRootPath(){
    return gApp.absoluteRootPath();
}

function absoluteURL(url){
    return gApp.absoluteURL(url);
}

function absoluteRootURL(){
    return gApp.absoluteRootURL();
}

function absoluteDataRootPath(){
    return gApp.absoluteDataRootPath();
}

function absoluteDataPath(path){
    return gApp.absoluteDataPath(path);
}

function absoluteDatabasePath(path){
    return gApp.absoluteDatabasePath(path);
}

/*Checks if the app is running from folder or packed state (ex. zip)*/
function isPacked(){
    return gApp.isPacked();
}

function isPackageReadOnly(){
    return gApp.isPackageReadOnly();
}

/*path must be a relative path no need to specify '/' at the beggining
It checks the path in the app data folder
*/
function isPathExists(path){
    return gApp.isPathExists(path);
}

/*Same as isPathExists*/
function isFile(path){
    return gApp.isFile(path);
}

function getAppManifest(){
    return gApp.getAppManifest();
}

function getDefaultBackgroundImageURL(){
    return gApp.getDefaultBackgroundImageURL();
}
