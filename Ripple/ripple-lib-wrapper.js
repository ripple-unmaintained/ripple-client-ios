window.onerror = function(err) {
    log('window.onerror: ' + err)
}
document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false)
function onBridgeReady(event) {
    var bridge = event.bridge
    bridge.init(function(message, responseCallback) {
                //log('JS got a message', message)
                var data = { 'Javascript Responds':'Wee!' }
                //log('JS responding with', data)
                responseCallback(data)
                })

    var remote = ripple.Remote.from_config({
                                           "trace" : true,
                                           "websocket_ip" : "s1.ripple.com",
                                           "websocket_port" : 443,
                                           "websocket_ssl" : true
                                           });

   bridge.registerHandler('account_information', function(data, responseCallback) {
                            remote.request_account_info(data['ripple_address'])
                            .on('success', function (result) {
                              responseCallback(result)
                            })
                            .on('error', function (result) {
                                console.error(result)
                                responseCallback(result)
                            })
                            .request();
                          })



   bridge.registerHandler('connect', function(data, responseCallback) {
                            remote.connect();
                          })


   remote.on('connected', function () {
     bridge.callHandler('connected', null, function(response) {
     })
     remote.on('disconnected', function () {
       bridge.callHandler('disconnected', null, function(response) {
       })
     })

     // remote.on('ledger_closed', function (ledger) {
     //   bridge.callHandler('ledger_closed', ledger, function(response) {
     //   })
     // });
   });



}
