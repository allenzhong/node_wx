https = require 'https'
util = require 'util'
modelutil = require './modelUtil'
Configuration = require '../config/config'
FollowerModel = require '../model/follower'
FollowerService = require '../service/followerService'

configInstance = Configuration.getInstance()

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

exports.getFollowersFromDB = (callback)->
    db = configInstance.getDBConnection()
    service = new FollowerService(db)
    service.find 'weixin/follower',null,(docs)->
      followers = service.parseDocs(docs)
      callback followers

exports.countFollowers = (callback)->
    db = configInstance.getDBConnection()
    service = new FollowerService(db)
    service.count 'weixin/count_follower',(sum)->
      callback sum



exports.saveFollowersOpenId = (json)->
  if (json.errcode)
    return
  console.log JSON.stringify(json.data.openid)
  array = json.data.openid
  for id in array
    console.log "Id" + id
    follower = new FollowerModel(id,null,1,id)
    obj = follower.getObject()
    db = configInstance.getDBConnection()
    service = new FollowerService(db)
    service.save obj,(err)->

exports.saveFollowerFullInfo = (json)->
    console.log "saveFollowerFullInfo" + JSON.stringify json
    db = configInstance.getDBConnection()
    service = new FollowerService(db)
    openid = json.openid
    console.log "openid -> " + openid
    service.get openid,(err,doc)->
      console.log "service.get json.openid,(doc) " + doc
      if(doc.resource =='follower')
        follower = new FollowerModel()
        console.log "parseDoc before"
        follower.parseDoc(doc)
        console.log "parseDoc"
        follower.setObject(json)
        # console.log follower.getObject()
        follower.id = doc.id
        follower.rev = doc.rev
        obj = follower.getObject()
        service.save obj,(err)->

# save follower
exports.saveFollower = (follower)->
  db = configInstance.getDBConnection()
  obj = follower.getObject()
  service = new FollowerService(db)
  service.save obj,(err)->
    if err
      console.log err.message

exports.pasreFollowersResponseJson = (json)->
    array = json.data.openid
    result = []
    for id in array
      console.log "Id " + id
      follower = new FollowerModel(id,null,1,id)
      result.push(follower.getObject())
    console.log "parse -> " + JSON.stringify result
    return {followers:result}
