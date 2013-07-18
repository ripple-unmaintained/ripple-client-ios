window.onerror = function(err) {
	log('window.onerror: ' + err)
}
document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false)
function onBridgeReady(event) {
	var bridge = event.bridge
	var account
	bridge.init(function(message, responseCallback) {
                //log('JS got a message', message)
                var data = { 'Javascript Responds':'Wee!' }
                //log('JS responding with', data)
                responseCallback(data)
            })

	var remote = ripple.Remote.from_config({
		"trace" : true,
		"trusted" : true,
		"websocket_ip" : "s1.ripple.com",
		"websocket_port" : 443,
		"websocket_ssl" : true
	});

	bridge.registerHandler('subscribe_ripple_address', function(data, responseCallback) {
		remote.accounts.request_subscribe([data['ripple_address']])
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})



	bridge.registerHandler('request_wallet_accounts', function(data, responseCallback) {
		remote.request_wallet_accounts(data['seed'])
		.on('success', function (result) {
			account = result
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})


	bridge.registerHandler('account_info', function(data, responseCallback) {
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

	bridge.registerHandler('account_lines', function(data, responseCallback) {
		remote.request_account_lines(data['ripple_address'])
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})

	bridge.registerHandler('account_tx', function(data, responseCallback) {
		remote.request_account_tx(data['ripple_address'])
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})


	bridge.registerHandler('account_offers', function(data, responseCallback) {
		remote.request_account_offers(data['ripple_address'])
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})




	remote.on('connected', function () {
		bridge.callHandler('connected', null, function(response) {
		})

		// Subscribe
		remote.request_subscribe(["ledger"])
		.on('success', function (result) {
			bridge.callHandler('subscribe_ledger', result, function(response) {
			})
		})
		.on('error', function (result) {
			console.error(result)
			bridge.callHandler('subscribe_ledger_error', result, function(response) {
			})
		})
		.request();

		remote.request_subscribe(["server"])
		.on('success', function (result) {
			bridge.callHandler('subscribe_server', result, function(response) {
			})
		})
		.on('error', function (result) {
			console.error(result)
			bridge.callHandler('subscribe_server_error', result, function(response) {
			})
		})
		.request();
	})

	bridge.registerHandler('connect', function(data, responseCallback) {
		remote.connect();
	})


	// remote.on('ledger_closed', function (ledger) {
	//   bridge.callHandler('ledger_closed', ledger, function(response) {
	//   })
	// });

  // remote.on('disconnected', function () {
  //   bridge.callHandler('disconnected', null, function(response) {
  //   })
  // })



}
