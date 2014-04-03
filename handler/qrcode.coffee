request = require 'request'
modelutil = require './modelUtil'
path = __dirname + "/../" + "public/images/"
moment = require "moment"
fs = require 'fs'


token="KRNWN3Kx80_mHDZwMc1WR3LXBiJvs6c2JQqTgia8q7-Izej1YaUwcy-mkyUELcwJ7CAgkqnminimgXpXtwJKKBZtrWa7rnhIFMQ5Gx4JByCUHMAnosQWUoEYzJW_vjgOdx7Q1M4BX96ty5081MnDLQ"
exports.test = ()->

 requestPermanetCode 123,token,(res)->
   console.log res.ticket
   savePic(res.ticket)
   return
 return

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


