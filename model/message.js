//For recive message and send message with different types

var xmlreader = require("xmlreader");
var xmlbuilder = require("xmlbuilder");

//Handle Message,Return Json as Parameter to Callback method
//callback(sending xml)
exports.handleMsg = function(xml, callback) {
    readXml(xml, function(json) {
        if (json.MsgType == "event") {
            console.log("it's event ->" + JSON.stringify(json));
            buildEvent(json, callback);
        } else {
            buildXml(json, callback);
        }
    });
};


//Handle xml 
//callback(json)
readXml = function(xml, callback) {
    xmlreader.read(xml, function(err, res) {
        //console.log("xmlreader.read");
        var json = {
            ToUserName: res.xml.ToUserName.text(),
            FromUserName: res.xml.FromUserName.text(),
            CreateTime: res.xml.CreateTime.text(),
            MsgType: res.xml.MsgType.text()
        };

        if (json.MsgType == "text") {
            json.Content = res.xml.Content.text();
            jsonMsgId = res.xml.MsgId.text();
        } else if (json.MsgType == "image") {
            jsonMsgId = res.xml.MsgId.text();
            json.PicUrl = res.xml.PicUrl.text();
            json.MediaId = res.xml.MediaId.text();
        } else if (json.MsgType == "voice") {
            json.MediaId = res.xml.MediaId.text();
            jsonMsgId = res.xml.MsgId.text();
            json.Format = res.xml.Format.text();
        } else if (json.MsgType == "video") {
            jsonMsgId = res.xml.MsgId.text();
            json.MediaId = res.xml.MediaId.text();
            json.ThumbMediaId = res.xml.ThumbMediaId.text();
            //With Viedo,it must be get its Title,Description for sending xml
        } else if (json.MsgType == "location") {
            json.Location_X = res.xml.Location_X.text();
            json.Location_Y = res.xml.Location_Y.text();
            json.Scale = res.xml.Scale.text();
            json.Label = res.xml.Label.text();
            jsonMsgId = res.xml.MsgId.text();
        } else if (json.MsgType == "link") {
            json.Title = res.xml.Title.text();
            json.Description = res.xml.Description.text();
            json.Url = res.xml.Url.text();
            jsonMsgId = res.xml.MsgId.text();
        } else if (json.MsgType == "event") {
            json.Event = res.xml.Event.text();
            if (json.Event == "CLICK" || json.Event == "VIEW") {
                json.EventKey = res.xml.EventKey.text();
            }
        }

        callback(json);
    });
};

buildXml = function(json, callback) {
    //console.log("buildXml");
    var xml = xmlbuilder.create("xml");
    xml.ele("ToUserName").dat(json.FromUserName);
    xml.ele("FromUserName").dat(json.ToUserName);
    xml.ele("CreateTime").dat(json.CreateTime);
    //xml.ele("MsgType").dat(json.MsgType);
    xml.ele("MsgType").dat("text");
    if (json.MsgType == "text") {

        xml.ele("Content").dat("It's text message");

    } else if (json.MsgType == "image") {

        // xml.ele("Image").ele("MediaId").dat(json.MediaId);
        xml.ele("Content").dat("It's image message");
    } else if (json.MsgType == "voice") {

        //xml.ele("Voice").ele("MediaId").dat(json.MediaId);
        xml.ele("Content").dat("It's voice message");
    } else if (json.MsgType == "video") {
        // json.MediaId = res.xml.MediaId.text();
        // json.ThumbMediaId = res.xml.ThumbMediaId.text();
        //With Viedo,it must be get its Title,Description for sending xml
        xml.ele("Content").dat("It's video message");
    } else if (json.MsgType == "location") {
        //do something for location bussiness logic
        xml.ele("Content").dat("It's location message");
    } else if (json.MsgType == "link") {
        //do something for link bussiness logic
        xml.ele("Content").dat("It's link message");
    }
    //console.log(xml);
    callback(xml);
};

buildEvent = function(json, callback) {
    var xml = xmlbuilder.create("xml");
    xml.ele("ToUserName").dat(json.FromUserName);
    xml.ele("FromUserName").dat(json.ToUserName);
    xml.ele("CreateTime").dat(json.CreateTime);
    if (json.Event == "subscribe") {
        xml.ele("Content").dat("谢谢关注众云测试平台");
    } else if (json.Event == "subscribe") {
        xml.ele("Content").dat("希望再次关注众云测试平台");
    } else if (json.Event == "CLICK" || json.Event == "VIEW") {
        //handle menu
        var menuName = handleMenu(json.EventKey);
        xml.ele("Content").dat("点击菜单 ：" + menuName);
    }
    console.log("xml -> " + xml);
    callback(xml);
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

handleMenu = function(key) {
    var button = menuJson.button;
    for (var i = 0; i < button.length; i++) {
        if (button[i].sub_button) {
            var sub_button = button[i].sub_button;
            for (var j = 0; j < sub_button.length; j++) {
                if (sub_button[j].key != "undefined" && sub_button[j].key == key) {
                    return sub_button[j].name;
                } else if (sub_button[j].url != "undefined" && sub_button[j].url == key) {
                    return sub_button[j].name;
                }
            }
        } else if (button[i].key != "undefined" && button[i].key == key) {
            return button[i].name;
        } else if (button[i].url != "undefined" && button[i].url == key) {
            return button[i].name;
        }
    }
};