var crypto = require("crypto");
var http = require("http");
var https = require("https");
var util = require("util");
var xmlreader = require("xmlreader");
var xmlbuilder = require("xmlbuilder");
var xmlLib = require("xml");
var message = require("../model/message");
var user = require("../model/user");
/*
 * GET home page.
 */
var token = "allenzhong";

exports.index = function(req, res) {
    var echostr = req.param("echostr");
    var result = checkSignature(req);
    if (result) {
        res.send(echostr);
    } else {
        res.send("false");
    }
};

exports.create_menu = function(req, res) {
    getAccessToken(function(token) {
        console.log(token);
        createMenu(token, function(ress) {
            var resJson = {
                msg: ress.responseText,
                token: token
            };
            res.send(resJson);
        });
    });
};

exports.doMessage = function(req, res) {
    //console.log(req.rawBody);
    //res.send(req.rawBody);
    message.handleMsg(req.rawBody, function(xml) {
        res.header('Content-Type', 'text/xml');
        res.send(xml.end({
            pretty: true,
            indent: '  ',
            newline: '\n'
        }));
    });
};

exports.followers = function(req, res) {
    getAccessToken(function(access_token) {
        user.getFollowers(access_token, null, function(json) {
            res.render('followers', json);
        });
    });
    //user.getFollowers()
};

//Check Wei Xin Signature
checkSignature = function(req) {
    var signature = req.param("signature");
    var timestamp = req.param("timestamp");
    var nonce = req.param("nonce");
    var array = [token, timestamp, nonce];
    // console.log(array);
    var sortArray = array.sort();
    var str = sortArray.join("");
    var shasum = crypto.createHash("sha1");
    shasum.update(str);
    var hex = shasum.digest('hex');
    // console.log("hex: " + hex);
    if (signature == hex)
        return true;
    else
        return false;
};

var appID = "wxba50ad44bb9be2db";
var appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25";
var accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s";
var createMenuUrl = " https://api.weixin.qq.com/cgi-bin/menu/create?access_token=%s";
//Get Access Token,GET
//callback(json)
// json: {
//     "access_token": "xxx", 
//     "expires_in": 7200
// }
getAccessToken = function(callback) {
    var url = util.format(accessTokenUrl, appID, appsecrect);
    console.log("access url :" + url);
    https.get(url, function(res) {
        var body = "";
        res.on('data', function(d) {
            body += d;
        });
        res.on('end', function() {
            console.log("body: " + body);
            var json = JSON.parse(body);
            callback(json.access_token);
        });
    });
};

var menuJson = {
    button: [{
        type: "click",
        name: "众云查单",
        key: "V1001_TODAY_MUSIC"
    }, {
        type: "click",
        name: "众云定位",
        key: "V1001_TODAY_SINGER"
    }, {
        name: "菜单",
        sub_button: [{
            type: "view",
            name: "关于我们",
            url: "http://www.nuubiz.com/"
        }, {
            type: "view",
            name: "打开系统",
            url: "http://www.nuubiz.com/"
        }, {
            type: "click",
            name: "赞一下我们",
            key: "V1001_GOOD"
        }]
    }]
};

//create menu,POST
createMenu = function(token, callback) {
    var url = util.format(createMenuUrl, token);
    console.log("menu url:-> " + url);
    var jsonString = JSON.stringify(menuJson);
    console.log("json length", jsonString.length);

    var headers = {
        'Content-Type': 'text/html;chartset=utf-8',
        'Content-Length': jsonString.length,
        'encoding': "utf-8"
    };
    var options = {
        host: "api.weixin.qq.com",
        port: 443,
        path: "/cgi-bin/menu/create?access_token=" + token,
        method: "POST",
        //headers: headers
    };
    var req = https.request(options, function(res) {
        console.log("res status :" + res.statusCode);
        res.on('data', function(chunk) {
            console.log("CreateMenuRes:" + chunk);
        });
        if (typeof(callback) == "function")
            callback(res);
    });
    console.log("jsonString:->" + jsonString);
    req.write(jsonString);
    req.end();
};