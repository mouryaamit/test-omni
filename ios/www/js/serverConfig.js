var ServerConfig;

(function(){
    "use strict";

    // *****  CNB Test Setup @ Albany
    var urlStr = 'http://test15.deposit2day.com/ConsumerService/ConsumerService.asmx';
    var urlIVSStr = "http://test15.deposit2day.com//ValidationService/VSoftRemoteSvc.asmx";

    // *****  Dev India
    //var urlStr = 'http://115.113.85.7/MobileMerchant/ConsumerService.asmx';
    //var urlIVSStr = "http://115.113.85.7/MMValidationService/VSoftRemoteSvc.asmx";

    // *****  Sit India
    //var urlStr = "http://115.113.85.15/ConsumerSvc/ConsumerService.asmx";
    //var urlIVSStr = "http://115.113.85.15/ValidationService/VSoftRemoteSvc.asmx";

    ServerConfig = {

        'url'               : urlStr,
        'urlIVS'            : urlIVSStr,
        'institutionId'     : '2',
        'contentType'       : 'text/xml',

        'sessionTimeout'    : 300000,       // Milli Seconds,
        'userName'          : 'dennis',
        'password'          : 'Dennis@123'

    };

})();
