var express = require('express');
var router = express.Router();
var contract_address; // contract 'Bank' address
var user; // msg.sender



router.get('/',
function(req, res) {
	res.render('index', {
		title: '合约地址'
	});
});

router.post('/',
function(req, res) {
	contract_address = req.body.contract_address;
	console.log(contract_address);
	res.redirect('/');
});



router.get('/user',
function(req, res) {
	res.render('user', {
		title: '切换用户'
	});
});

router.post('/user',
function(req, res) {
	user = req.body.user;
	console.log(user);
	res.redirect('/user');
});



router.get('/balance',
function(req, res) {
	res.render('balance', {
		title: '查询账户存款'
	});
});

router.post('/balance',
function(req, res) {
	var account_checked = req.body.account_checked,

	http = require('http');
	var arr = [];
	arr.push(account_checked);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "check_balance",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);
	
	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		} 
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
			_json = JSON.parse(_data)
			console.log("\nbalance: ", parseInt(_json.output))
		});
	});

	req.write(content);
	req.end();
	res.redirect('/balance');
});



router.get('/deposit',
function(req, res) {
	res.render('deposit', {
		title: '存款'
	});
});

router.post('/deposit',
function(req, res) {
	var money = req.body.money;

	http = require('http');
	var arr = [];
	arr.push(money);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "deposit",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);

	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		} 
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
		});
	});

	req.write(content);
	req.end();
	res.redirect('/deposit');
});



router.get('/trusted',
function(req, res) {
	res.render('trusted', {
		title: '签署信任合同'
	});
});

router.post('/trusted',
function(req, res) {
	var end_time = req.body.end_time,
	money = req.body.money;
	password = req.body.password;

	http = require('http');
	var arr = [];
	arr.push(end_time);
	arr.push(money);
	arr.push(password);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "trusted",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);

	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		} 
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
		});
	});

	req.write(content);
	req.end();
	res.redirect('/trusted');
});



router.get('/deal',
function(req, res) {
	res.render('deal', {
		title: '企业间交易'
	});
});

router.post('/deal',
function(req, res) {
	var address_to = req.body.address_to
	money = req.body.money;

	http = require('http');
	var arr = [];
	arr.push(address_to);
	arr.push(money);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "deal",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);

	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		} 
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
		});
	});

	req.write(content);
	req.end();
	res.redirect('/deal');
});



router.get('/loan',
function(req, res) {
	res.render('loan', {
		title: '企业从银行取款'
	});
});

router.post('/loan',
function(req, res) {
	var money = req.body.money;

	http = require('http');
	var arr = [];
	arr.push(money);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "loan",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);

	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		} 
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
		});
	});

	req.write(content);
	req.end();
	res.redirect('/loan');
});



router.get('/repay',
function(req, res) {
	res.render('repay', {
		title: '还款'
	});
});

router.post('/repay',
function(req, res) {
	var time = req.body.time;

	http = require('http');
	var arr = [];
	arr.push(time);

	var post_data = {
		"useAes": false,
		"user": user,
		"contractName": "Bank",
		"contractAddress": contract_address,
		"funcName": "repay",
		"funcParam": arr,
		"groupId": "1"
	};

	var content = JSON.stringify(post_data);

	var options = {  hostname: '127.0.0.1',
		  port: 5002,
		  path: '/WeBASE-Front/trans/handle',
		  method: 'POST',
		  headers: {
			"Content-type": "application/json"
		}
	};

	var req = http.request(options,
	function(res) {
		var _data = '';

		res.on('data',
		function(chunk) {
			_data += chunk;
		});

		res.on('end',
		function() {
			console.log("result:", _data)
		});
	});

	req.write(content);
	req.end();
	res.redirect('/repay');
});



module.exports = router;
