request = require 'request'
modelutil = require './modelUtil'
path = __dirname + "/../" + "public/images/"
moment = require "moment"
fs = require 'fs'


token="yeQEu_OrXQanGC_G56BZ7Be0WTQLmEK6xCTRwXiKsHOyAK6cKhkdf9V6hGsd42L9sgQeiPyDQcGgen1aJrKew50sXTCc58o-F6GmVVauQ6jBeEGd09JZjoQcL54TB_Sqh42TS2Bs2tsYsV2K1e-DSg"
exports.test = ()->
 requestTempCode 123,1800,token,(res)->
   console.log res.ticket
   savePic(res.ticket)
   return
 requestPermanetCode 1234,token,(res)->
   console.log res.ticket
   savePic(res.ticket)
   return
 return

exports.savePic = (ticket)->
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
  callback body
 return


