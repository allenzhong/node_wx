var crypto = require("crypto");
var http = require("http");
var https = require("https");
var util = require("util");
var xmlreader = require("xmlreader");
var xmlbuilder = require("xmlbuilder");
var xmlLib = require("xml");
var message = require("../model/message");
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
    // readXml(req.rawBody, function(json) {
    //     //console.log("json - >" + JSON.stringify(json));
    //     buildXml(json, function(xml) {
    //         console.log("xml - > " + xml);
    //         //res.send(xml);
    //         res.header('Content-Type', 'text/xml');
    //         res.send(xml.end({
    //             pretty: true,
    //             indent: '  ',
    //             newline: '\n'
    //         }));
    //     });
    // });
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
    https.get(url, function(res) {
        console.log("after access token ->" + res.responseText);
        var json = JSON.parse(res.responseText);
        callback(json.access_token);
    });
};

var menuJson = {
    button: [{
        type: "click",
        name: "今日歌曲",
        key: "V1001_TODAY_MUSIC"
    }, {
        type: "click",
        name: "歌手简介",
        key: "V1001_TODAY_SINGER"
    }, {
        name: "菜单",
        sub_button: [{
            type: "view",
            name: "搜索",
            url: "http://www.soso.com/"
        }, {
            type: "view",
            name: "视频",
            url: "http://v.qq.com/"
        }]
    }]
};
//create menu,POST
createMenu = function(token, callback) {
    var url = util.format(createMenuUrl, token);
    var jsonString = JSON.stringify(menuJson);
    var headers = {
        'Content-Type': 'application/json',
        'Content-Length': jsonString.length
    };
    var options = {
        host: "https://api.weixin.qq.com",
        port: 443,
        path: "cgi-bin/menu/create?access_token=" + token,
        method: "POST",
        headers: headers
    };
    var req = https.request(options, function(res) {
        if (typeof(callback) == "function")
            callback(res);
    });
    req.write(jsonString);
    req.end();
};