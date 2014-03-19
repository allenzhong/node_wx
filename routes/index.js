var crypto = require("crypto");

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