https = require 'https'
util = require 'util'
modelutil = require './modelUtil'

getFollowersUrl = "https://api.weixin.qq.com/cgi-bin/user/get?access_token=%s&next_openid=%s"
getFollowerUrl = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=%s&openid=%s&lang=zh_CN"
sendMsgUrl = "https://api.weixin.qq.com/cgi-bin/message/custom/send?access_token=%s"
# Get Followers, 10k followers/per request.
# Use next_openid for next request.
# callback(result json) ->{"total":2,"count":2,"data":{"openid":["","OPENID1","OPENID2"]},"next_openid":"NEXT_OPENID"}
exports.getFollowers = (access_token,next_openid,callback)->
  # nextUrl = util.format next_openidUrl, next_openid
  url = util.format getFollowersUrl,access_token,next_openid
  console.log "followers url-> " + url
  modelutil.getJson(url,callback);

exports.getFollower = (access_token,open_id,callback)->
  url = util.format getFollowerUrl ,access_token, open_id
  console.log "single follower url ->" + url
  modelutil.getJson(url,callback);

exports.sendmsg = (access_token,open_id,type='text',content,callback)->
  host = "api.weixin.qq.com"
  path = "/cgi-bin/message/custom/send?access_token="
  json = {
        touser:open_id,
        msgtype:type,
        text:{
             content:content
        }
  }
  modelutil.postJson(host,path,access_token,json,callback);