//************   Change Orientation JS Code **************
//********************************************************
//************  Native Code Plugin for iOS only. ****************
//********************************************************

window.ChangeOrientation = {
    
    change : function(orientation, success, failure){
        var args = {};
        args.orientation = orientation;
        //handle android using native code because toDataURL is not supported on android version < 3
        
        cordova.exec(success, failure, "ChangeOrientation", "changeOrientation",  ['set', orientation]);
    }
};

