var xmlreader = require("xmlreader");
var xmlbuilder = require("xmlbuilder");

//Handle Message,Return Json as Parameter to Callback method
//callback(sending xml)
exports.handleMsg = function(xml, callback) {
    readXml(xml, function(json) {
        buildXml(json, callback);
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
            MsgType: res.xml.MsgType.text(),
            MsgId: res.xml.MsgId.text()
        };

        if (json.MsgType == "text") {
            json.Content = res.xml.Content.text();
        } else if (json.MsgType == "image") {
            json.PicUrl = res.xml.PicUrl.text();
            json.MediaId = res.xml.MediaId.text();
        } else if (json.MsgType == "voice") {
            json.MediaId = res.xml.MediaId.text();
            json.Format = res.xml.Format.text();
        } else if (json.MsgType == "video") {
            json.MediaId = res.xml.MediaId.text();
            json.ThumbMediaId = res.xml.ThumbMediaId.text();
            //With Viedo,it must be get its Title,Description for sending xml
        } else if (json.MsgType == "location") {
            json.Location_X = res.xml.Location_X.text();
            json.Location_Y = res.xml.Location_Y.text();
            json.Scale = res.xml.Scale.text();
            json.Label = res.xml.Label.text();
        } else if (json.MsgType == "link") {
            json.Title = res.xml.Title.text();
            json.Description = res.xml.Description.text();
            json.Url = res.xml.Url.text();
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
    xml.ele("MsgType").dat(json.MsgType);
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