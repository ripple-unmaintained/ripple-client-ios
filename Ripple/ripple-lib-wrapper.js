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

   bridge.registerHandler('rippleRemoteConnect', function(data, responseCallback) {
                          //log('ObjC called testJavascriptHandler with', data)
                          var responseData = { 'Javascript Says':'Right back atcha!' }
                          //log('JS responding with', responseData)
                          responseCallback(responseData)
                          })

    var remote = ripple.Remote.from_config({
                                           "trace" : true,
                                           "websocket_ip" : "s1.ripple.com",
                                           "websocket_port" : 443,
                                           "websocket_ssl" : true
                                           });
    remote.connect();

    remote.once('connected', function () {
                remote.request_account_info("r9kiSEUEw6iSCNksDVKf9k3AyxjW3r1qPf")
                .on('success', function (result) {
                    //document.write("Balance " + result.account_data.Balance + "<br>");

                    bridge.callHandler('rippleRemoteConnectedCallback', result, function(response) {
                                       //document.write("Connected response: " + response + "<br>");
                                       })
                    })
                .on('error', function (result) {
                    console.error(result);
                    })
                .request();

                remote.on('ledger_closed', function (ledger) {
                              bridge.callHandler('rippleRemoteLedgerClosedCallback', ledger, function(response) {
                                                 })
                              });
                    });
}
