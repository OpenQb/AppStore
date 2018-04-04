.pragma library

var gCore;
var setup = function(core) {
    gCore = core;
}

function diagonal(w,h)
{
    return gCore.diagonal(w,h);
}

function dpi(){
    return gCore.dpi();
}

function scale(num){
    return gCore.scale(num);
}

function screenWidth(){
    return gCore.screenWidth();
}

function screenHeight(){
    return gCore.screenHeight();
}

function toBase64(data){
    return gCore.toBase64(data);
}

function fromBase64(data){
    return gCore.fromBase64(data);
}

function isReady(){
    if(gCore) return true;
    else return false;
}
