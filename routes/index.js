var crypto = require("crypto");
var http = require("http");
var util = require("util");
var xmlreader = require("xmlreader");
var xmlbuilder = require("xmlbuilder");
var xmlLib = require("xml");
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
    //console.log(req.rawBody);
    //res.send(req.rawBody);
    readXml(req.rawBody, function(json) {
        //console.log("json - >" + JSON.stringify(json));
        buildXml(json, function(xml) {
            console.log("xml - > " + xml);
            //res.send(xml);
            res.header('Content-Type', 'text/xml');
            res.send(xml.end({
                pretty: true,
                indent: '  ',
                newline: '\n'
            }));
        });
    });
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
//Handle xml 
//callback(json)
readXml = function(xml, callback) {
    xmlreader.read(xml, function(err, res) {
        console.log("xmlreader.read");
        var json = {
            ToUserName: res.xml.ToUserName.text(),
            FromUserName: res.xml.FromUserName.text(),
            CreateTime: res.xml.CreateTime.text(),
            MsgType: res.xml.MsgType.text(),
            Content: res.xml.Content.text(),
            MsgId: res.xml.MsgId.text()
        };
        callback(json);
    });
};

buildXml = function(json, callback) {
    //console.log(JSON.stringify(json));
    // var xml = xmlbuilder.create({
    //     xml: {
    //         ToUserName: {
    //             dat: json.FromUserName
    //         },
    //         FromUserName: {
    //             cdata: json.ToUserName
    //         },
    //         CreateTime: "<![CDATA[" + json.CreateTime + "]]>",
    //         MsgType: "<![CDATA[" + json.MsgType + "]]>",
    //         Content: "<![CDATA[" + json.Content + "]]>"
    //     }
    // });
    console.log("buildXml");
    var xml = xmlbuilder.create("xml");
    xml.ele("ToUserName").dat(json.FromUserName);
    xml.ele("FromUserName").dat(json.ToUserName);
    xml.ele("CreateTime").dat(json.CreateTime);
    xml.ele("MsgType").dat(json.MsgType);
    xml.ele("Content").dat(json.Content);
    //console.log(xml);
    callback(xml);
};