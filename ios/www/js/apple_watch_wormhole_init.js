(function(){
    "use strict";

    var sendDataToWatch = function(){
        var testData = " Please login to the IRIS iOS App";
        applewatch.sendMessage(testData, "sendToWatchData", function(){console.log("data sent");}, function(){console.log("data send Failed");});
    };


    window.setTimeout(function(){

        applewatch.init(function(){
                console.log("init Success");

                applewatch.addListener("getDataFromMobile", function (message) {
                    console.log(message);
                    sendDataToWatch();
                });

            },

            function(){
                console.log("init Fail");
            },

            "group.com.vsoft.omni");

    } , 1000);

})();