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
		//"trace" : true,
		"trusted" : true,
		"websocket_ip" : "s1.ripple.com",
		"websocket_port" : 443,
		"websocket_ssl" : true,
		"local_signing" : true
	});

	// XRP Account Balance
	bridge.registerHandler('account_info', function(data, responseCallback) {
		remote.set_secret(data.account, data.secret);
		remote.request_account_info(data.account)
		.on('success', function (result) {
			responseCallback(result)
		})
		.on('error', function (result) {
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
			responseCallback(result)
		})
		.request();
	})

	// Submit payment
	// {"currency":"XRP","amount":1000000,"recipient_address":"rvYAfWj5gh67oV6fW32ZzP3Aw4Eubs59B","account":"rHQFmb4ZaZLwqfFrNmJwnkizb7yfmkRS96"}
	bridge.registerHandler('send_transaction', function(data, responseCallback) {
		try {


			//var currency = $scope.send.currency.slice(0, 3).toUpperCase();
			//var amount = Amount.from_human(""+$scope.send.amount+" "+currency);
			//var addr = $scope.send.recipient_address;
			//var dt = $scope.send.dt ? $scope.send.dt : webutil.getDestTagFromAddress($scope.send.recipient);

			remote.set_secret(data.account, data.secret);

			var currency = data.currency.slice(0, 3).toUpperCase();
			var amount = ripple.Amount.from_human(""+data.amount+" "+currency)
			var addr = data.recipient_address

			amount.set_issuer(addr);

			// Make sure recipient address is valid
			remote.request_account_info(data.recipient_address)
			  .on('error', function (response_account_info) {
		      if (response_account_info.error === "remoteError" &&
		          response_account_info.remote.error === "actNotFound") {
		      	// Invalid address
		      	responseCallback(JSON.parse('{"error":"Account not found"}'))
		      	return;
		      } else {
		      	responseCallback(JSON.parse('{"error":"Validating address. Unknown error: '+response+'"}'))
		      	return;
		      }

			  })
			  .on('success', function (response_account_info) {
			    if (currency === "XRP") {
			    	var tx = remote.transaction()
			    	tx.payment(data.account, addr, amount.to_json())


			    	// Sending XRP
			    	tx.build_path(true);

			    	// Send transaction
				    tx.on('success', function (res) {
		  	    	responseCallback(res)
		  	    });
		  	    tx.on('error', function (res) {
		  	    	responseCallback(res)
		  	    });
		  	    tx.submit();
			    } else {
			    	// Calculate path
			      remote.request_ripple_path_find(data.account,
			                                              data.recipient_address,
			                                              amount)
			      // XXX Handle error response
		        .on('success', function (response_find_path) {
	            if (!response_find_path.alternatives || !response_find_path.alternatives.length) {
	              responseCallback(JSON.parse('{"error":"No Path"}'))
		      			return;
	            } else {
	            	//responseCallback(response_find_path)

	            	var tx = remote.transaction()
	            	tx.payment(data.account, addr, amount.to_json())

	              var base_amount = ripple.Amount.from_json(response_find_path.alternatives[0].source_amount);
	              tx.sendmax_feedback = base_amount.product_human(ripple.Amount.from_json('1.01'));

	              var prepared_paths = response_find_path.alternatives[0].paths_computed
	                ? response_find_path.alternatives[0].paths_computed
	                : response_find_path.alternatives[0].paths_canonical;
	              tx.paths(prepared_paths);

	              // Send transaction
	      		    tx.on('success', function (res) {
	        	    	responseCallback(res)
	        	    });
	        	    tx.on('error', function (res) {
	        	    	responseCallback(res)
	        	    });
	        	    tx.submit();
	            }
		        })
		        .on('error', function (response_find_path) {
	            responseCallback(JSON.parse('{"error":"Path_find: Unknown Error: '+response_find_path+'"}'))
	      			return;
		        })
		        .request();
			    }
			  })
			  .request();


		  }
			catch (e) {
				responseCallback("Exception");
			}
	})


	// Checking for valid account
	bridge.registerHandler('is_valid_account', function(data, responseCallback) {
		remote.request_account_info(data.account)
		  .on('error', function (response_account_info) {
	      if (response_account_info.error === "remoteError" &&
	          response_account_info.remote.error === "actNotFound") {
	      	// Invalid address
	      	responseCallback(JSON.parse('{"error":"Account not found"}'))
	      	return;
	      } else {
	      	responseCallback(JSON.parse('{"error":"Validating address. Unknown error: '+response+'"}'))
	      	return;
	      }

		  })
		  .on('success', function (response_account_info) {
		    responseCallback(JSON.parse('{"message":"Valid address: '+data.account+'"}'))
		  })
		  .request();
	})




	// Find paths between two accounts
	bridge.registerHandler('find_path_currencies', function(data, responseCallback) {
		var currency = data.currency.slice(0, 3).toUpperCase();
		var amount = ripple.Amount.from_human(""+data.amount+" "+currency)

  	// Calculate path
    remote.request_ripple_path_find(data.account,
                                            data.recipient_address,
                                            amount)
    // XXX Handle error response
    .on('success', function (response_find_path) {
      if (!response_find_path.alternatives || !response_find_path.alternatives.length) {
        responseCallback(JSON.parse('{"error":"No Path"}'))
  			return;
      } else {
      	responseCallback(response_find_path.destination_currencies)
      }
    })
    .on('error', function (response_find_path) {
      responseCallback(JSON.parse('{"error":"Path_find: Unknown Error: '+response_find_path+'"}'))
			return;
    })
    .request();
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


	// Subscribe
	bridge.registerHandler('subscribe_transactions', function(data, responseCallback) {
		//remote.set_secret(data.account, data.secret);
		// Subscribe
		remote.request_subscribe().accounts(data.account,false).request();
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

	// Disconnect to ripple network
	bridge.registerHandler('disconnect', function(data, responseCallback) {
		remote.disconnect();
	})

	// Testing purposes
	// remote.on('ledger_closed', function (ledger) {
	//   bridge.callHandler('ledger_closed', ledger, function(response) {
	//   })
	// });

	// Connected to ripple network
	remote.on('connect', function () {
		bridge.callHandler('connected', null, function(response) {
		})
	})

	remote.on('disconnect', function () {
		bridge.callHandler('disconnected', null, function(response) {
		})
	})

	remote.on('transaction', function (result) {
		bridge.callHandler('transaction_callback', result, function(response) {
		})
	})


	// Sets account
	bridge.registerHandler('set_account', function(data, responseCallback) {
		remote.account = data.account
		responseCallback(remote.account)
	})

	// Testing transaction decrypt
	// bridge.registerHandler('test_transaction', function(result, responseCallback) {
	// 	//responseCallback(result.meta)
	// 	rewriter = new JsonRewriter();
	// 	responseCallback(result.meta)
	// 	var rewrite = rewriter.processTxn(result.transaction, result.meta, remote.account)
	// 	responseCallback(rewrite)

	// 	//bridge.callHandler('transaction_callback', result, function(response) {
	// 	//})
	// })
}
