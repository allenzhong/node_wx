https = require 'https'
util = require 'util'

getFollowersUrl = "https://api.weixin.qq.com/cgi-bin/user/get?access_token=%s&next_openid=%s"
next_openidUrl = "&next_openid=%s"
# Get Followers, 10k followers/per request.
# Use next_openid for next request.
# callback(result json) ->{"total":2,"count":2,"data":{"openid":["","OPENID1","OPENID2"]},"next_openid":"NEXT_OPENID"}
exports.getFollowers = (access_token,next_openid,callback)->
  nextUrl = util.format next_openidUrl, next_openid
  url = util.format getFollowersUrl,access_token, nextUrl
  console.log "follower url-> " + url
  https.get url,(res)->
    body = ""
    res.on 'data',(d)->
      body = body + d
    res.on 'end',()->
      console.log 'followers body ->' + body
      json =  JSON.parse(body)
      callback json
