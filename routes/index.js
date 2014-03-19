var crypto = require("crypto");
var http = require("http");
var util = require("util");
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

exports.doMessage = function(req, res) {
    res.send(req);
};

//Check Wei Xin Signature
checkSignature = function(req) {
    var signature = req.param("signature");
    var timestamp = req.param("timestamp");
    var nonce = req.param("nonce");
    var array = [token, timestamp, nonce];
    console.log(array);
    var sortArray = array.sort();
    var str = sortArray.join("");
    var shasum = crypto.createHash("sha1");
    shasum.update(str);
    var hex = shasum.digest('hex');
    console.log("hex: " + hex);
    if (signature == hex)
        return true;
    else
        return false;
};

var appID = "wxba50ad44bb9be2db";
var appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25";
var accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s";
//Get Access Token
//callback(json)
getAccessToken = function(callback) {
    var url = util.format(accessTokenUrl, appID, appsecrect);
    http.get(url, function(res) {
        console.log(res.responseText);
        callback(res.responseText);
    });
};