// Generated by CoffeeScript 1.6.3
(function() {
  var getFollowerUrl, getFollowersUrl, https, modelutil, sendMsgUrl, util;

  https = require('https');

  util = require('util');

  modelutil = require('./modelUtil');

  getFollowersUrl = "https://api.weixin.qq.com/cgi-bin/user/get?access_token=%s&next_openid=%s";

  getFollowerUrl = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=%s&openid=%s&lang=zh_CN";

  sendMsgUrl = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=%s";

  exports.getFollowers = function(access_token, next_openid, callback) {
    var url;
    url = util.format(getFollowersUrl, access_token, next_openid);
    console.log("followers url-> " + url);
    return modelutil.getJson(url, callback);
  };

  exports.getFollower = function(access_token, open_id, callback) {
    var url;
    url = util.format(getFollowerUrl, access_token, open_id);
    console.log("single follower url ->" + url);
    return modelutil.getJson(url, callback);
  };

  exports.sendmsg = function(access_token, open_id, type, content, callback) {
    var host, json, path;
    if (type == null) {
      type = 'text';
    }
    host = "api.weixin.qq.com";
    path = "/cgi-bin/message/custom/send?access_token=";
    json = {
      touser: open_id,
      msgtype: type,
      text: {
        content: content
      }
    };
    return modelutil.postJson(host, path, access_token, json, callback);
  };

}).call(this);
