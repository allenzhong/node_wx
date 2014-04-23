request = require 'request'
modelutil = require './modelUtil'
path = __dirname + "/../" + "public/images/"
moment = require "moment"
fs = require 'fs'
Configuration = require '../config/config'
#Get config singleton instance
configInstance = Configuration.getInstance()

# token="KRNWN3Kx80_mHDZwMc1WR3LXBiJvs6c2JQqTgia8q7-Izej1YaUwcy-mkyUELcwJ7CAgkqnminimgXpXtwJKKBZtrWa7rnhIFMQ5Gx4JByCUHMAnosQWUoEYzJW_vjgOdx7Q1M4BX96ty5081MnDLQ"
# exports.test = ()->

#  requestPermanetCode 123,token,(res)->
#    console.log res.ticket
#    savePic(res.ticket)
#    return
#  return

exports.savePic = savePic= (ticket)->
 imgUrl = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=" +ticket
 filename = moment().unix() + Math.floor(Math.random()*10+1) + ".jpg"
 console.log "Getting image " + filename
 request( {url: imgUrl,encoding: null}).pipe(fs.createWriteStream(path+filename))
 return filename
    
###
Request a tempary code expire in 1800 second usually
callback(ticket)
###
exports.requestTempCode =requestTempCode= (scene_id, expire_seconds = 1800, token, callback) ->
 json = 
   expire_seconds: expire_seconds,
   action_name: "QR_SCENE",
   action_info: 
     scene: 
      scene_id: scene_id
 url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token="+token
 request.post {url:url,json:json},(e,r,body)->
  console.log "temp ticket"+body
  callback body
 return
###
Request a permanent code
callback(ticket)
###
exports.requestPermanetCode=requestPermanetCode= (scene_id,token,callback)->
 json = 
  action_name: "QR_LIMIT_SCENE"
  action_info: 
   scene: 
     scene_id: scene_id

 url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token="+token
 request.post {url:url,json:json},(e,r,body)->
  console.log body
  callback body
 return

# request a temp qrcode for a user 
# 1. random a scene number 0<x<65535
# 2. when get a ticket ,save it to redis
# 3, save to redis by following format(using semicolon to split)
#     openid:scend_value:ticket
exports.requestQRCodeForUser  = (openid,token,callback)->
  scene_id = randomSceneForUser()
  client = configInstance.getRedisClient()
  key = openid+":scene" 
  getValue = client.get key,(err,getValue)->
    console.log "get ->" + getValue + ": scene_id ->" + scene_id
    if(getValue)
      array = getValue.split(":")
      a_ticket = array[1]
      picName=array[2]
      callback a_ticket,picName
      return
    else
      requestTempCode scene_id,1800,token,(ticket)->
        console.log "ticket:->" +ticket
        # save to redis
        if(ticket)
          picName = savePic(ticket.ticket)
          value = scene_id+":"+ticket.ticket+":"+picName
          client.set(key,value)
          client.expire(key,600*3)
          # save another key-value: scene_id->openid to find who is owner of qrcode
          client.set("scene"+scene_id,openid)
          client.expire(scene_id,600*3)

        callback ticket,picName
        return
      return
    return



# Must modified after deployment
exports.randomSceneForUser =randomSceneForUser= ()->
  return Math.floor(Math.random()*1000)



