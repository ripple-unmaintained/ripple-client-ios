window.onerror = function(err) {
	log('window.onerror: ' + err)
}
document.addEventListener('WebViewJavascriptBridgeReady', onBridgeReady, false)
function onBridgeReady(event) {
	var bridge = event.bridge
	//var account
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

	// bridge.registerHandler('subscribe_ripple_address', function(data, responseCallback) {
	// 	remote.accounts.request_subscribe([data['ripple_address']])
	// 	.on('success', function (result) {
	// 		responseCallback(result)
	// 	})
	// 	.on('error', function (result) {
	// 		console.error(result)
	// 		responseCallback(result)
	// 	})
	// 	.request();
	// })

	// bridge.registerHandler('request_wallet_accounts', function(data, responseCallback) {
	// 	remote.request_wallet_accounts(data['seed'])
	// 	.on('success', function (result) {
	// 		account = result
	// 		responseCallback(result)
	// 	})
	// 	.on('error', function (result) {
	// 		console.error(result)
	// 		responseCallback(result)
	// 	})
	// 	.request();
	// })

	// XRP Account Balance
	bridge.registerHandler('account_info', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		remote.request_account_info(data.account)
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})

	// IOU Request Account Balances
	bridge.registerHandler('account_lines', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		remote.request_account_lines(data.account)
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})

	// Last transactions on account
	bridge.registerHandler('account_tx', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		remote.request_account_tx(data.params)
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})



	// Sending payment
	// Find payment path
	bridge.registerHandler('request_ripple_find_path', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		remote.request_ripple_path_find(data.src_account, data.dst_account, data.dst_amount)
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})

	// Submit payment
	// {"currency":"XRP","amount":1000000,"recipient_address":"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B","account":"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96"}
	bridge.registerHandler('send_transaction', function(data, responseCallback) {
		//var currency = $scope.send.currency.slice(0, 3).toUpperCase();
		//var amount = Amount.from_human(""+$scope.send.amount+" "+currency);
		//var addr = $scope.send.recipient_address;
		//var dt = $scope.send.dt ? $scope.send.dt : webutil.getDestTagFromAddress($scope.send.recipient);

		remote.set_secret(data.account, data.secret);


		var currency = data.currency.slice(0, 3).toUpperCase();
		var amount = ripple.Amount.from_human(""+data.amount+" "+currency)
		var addr = data.recipient_address
		//var dt =

		//responseCallback(amount.to_json())

		//amount.set_issuer(addr);

		var tx = remote.transaction()
		// What is a source tag?
		// what is a destination tag?

		tx.payment(data.account, addr, amount.to_json())

		//responseCallback("AFTER")

		//tx.source_tag(TODO)
		//tx.destination_tag(TODO)
		tx.payment(data.account, addr, amount.to_json())
		tx.build_path(true);

		//responseCallback("AFTER")

	    // if ($scope.send.alt) {
	    // 	tx.send_max($scope.send.alt.send_max);
	    // 	tx.paths($scope.send.alt.paths);
	    // } else {
	    // 	if (!amount.is_native()) {
	    // 		tx.build_path(true);
	    // 	}
	    // }
	    tx.on('success', function (res) {
	    	responseCallback(res)
	    });
	    tx.on('error', function (res) {
	    	responseCallback(res)
	    });
	    tx.submit();




	    // remote.request_submit()
	    // .on('success', function (result) {
	    // 	responseCallback(result)
	    // })
	    // .on('error', function (result) {
	    // 	console.error(result)
	    // 	responseCallback(result)
	    // })
	    // .request();
	})


	// Not yet needed for iOS app
	// bridge.registerHandler('account_offers', function(data, responseCallback) {
	// 	remote.set_secret(data.account, data.secret);
	// 	remote.request_account_offers(data.account)
	// 	.on('success', function (result) {
	// 		responseCallback(result)
	// 	})
	// 	.on('error', function (result) {
	// 		console.error(result)
	// 		responseCallback(result)
	// 	})
	// 	.request();
	// })

	// Subscribe to ledger and server after logged in
	bridge.registerHandler('subscribe_logged_in', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		// Subscribe
		remote.request_subscribe(["ledger","server"])
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
			console.error(result)
			responseCallback(result)
		})
		.request();
	})

	// Decrypts with sjcl library
	bridge.registerHandler('sjcl_decrypt', function(data, responseCallback) {
		try {
			responseCallback(JSON.parse(sjcl.decrypt(data.key, data.decrypt)))
		}
		catch (e) {
			responseCallback(null);
		}
	})

	// Connect to ripple network
	bridge.registerHandler('connect', function(data, responseCallback) {
		remote.connect();
	})


	// remote.on('ledger_closed', function (ledger) {
	//   bridge.callHandler('ledger_closed', ledger, function(response) {
	//   })
	// });

	// Connected to ripple network
	remote.on('connected', function () {
		bridge.callHandler('connected', null, function(response) {
		})
	})

	remote.on('disconnected', function () {
		bridge.callHandler('disconnected', null, function(response) {
		})
	})



}
