#For recive message and send message with different types
xmlreader = require("xmlreader")
xmlbuilder = require("xmlbuilder")
Configuration = require '../config/config'
MessageModel = require "../model/message"
MessageService = require("../service/messageService")
ArticleService = require '../service/articleService'
followerHandler = require './follower'
#for qrcode
Canvas = require 'canvas'
Image = Canvas.Image
qrcode = require('jsqrcode')(Canvas)
# for get image
request = require 'request'
image = new Image()
#Get config singleton instance
configInstance = Configuration.getInstance()
#Handle Message,Return Json as Parameter to Callback method
#callback(sending xml)
exports.handleMsg = (xml, callback) ->
  # console.log "event ->"
  console.log xml
  readXml xml, (json) ->
    if json.MsgType is "event"
      console.log "it's event ->" + JSON.stringify(json)
      buildEvent json, callback
    else
      saveMessage(json)
      buildXml json, callback
    return
  return

#decode image that include a  qrcode
decodeQRcode = (imgUrl,callback)->
  request {url: imgUrl,encoding: null}, (error, response, body) ->
    buff = new Buffer(body, 'binary');
    image.src = buff;
    try 
      result = qrcode.decode(image)
      callback null,result
      # console.log('result of qr code: ' + result)
    catch e
      callback e
      console.log('unable to read qr code')

saveMessage = (json)->
  console.log "saveMessage"
  dbConnection = configInstance.getDBConnection()
  msg = new MessageModel(null,null,json.ToUserName,json.FromUserName,json.CreateTime,json.MsgType,json)
  # msg.setObject()
  service = new MessageService(dbConnection)
  service.save msg,(err,obj)->

#Handle xml 
#callback(json)
readXml = (xml, callback) ->
  xmlreader.read xml, (err, res) ->
    
    #console.log("xmlreader.read");
    json =
      ToUserName: res.xml.ToUserName.text()
      FromUserName: res.xml.FromUserName.text()
      CreateTime: res.xml.CreateTime.text()
      MsgType: res.xml.MsgType.text()

    if json.MsgType is "text"
      json.Content = res.xml.Content.text()
      jsonMsgId = res.xml.MsgId.text()
    else if json.MsgType is "image"
      jsonMsgId = res.xml.MsgId.text()
      json.PicUrl = res.xml.PicUrl.text()
      json.MediaId = res.xml.MediaId.text()
    else if json.MsgType is "voice"
      json.MediaId = res.xml.MediaId.text()
      jsonMsgId = res.xml.MsgId.text()
      json.Format = res.xml.Format.text()
      json.Recognition = res.xml.Recognition.text()  unless res.xml.Recognition is "undefined"
    else if json.MsgType is "video"
      jsonMsgId = res.xml.MsgId.text()
      json.MediaId = res.xml.MediaId.text()
      json.ThumbMediaId = res.xml.ThumbMediaId.text()
    
    #With Viedo,it must be get its Title,Description for sending xml
    else if json.MsgType is "location"
      json.Location_X = res.xml.Location_X.text()
      json.Location_Y = res.xml.Location_Y.text()
      json.Scale = res.xml.Scale.text()
      json.Label = res.xml.Label.text()
      jsonMsgId = res.xml.MsgId.text()
    else if json.MsgType is "link"
      json.Title = res.xml.Title.text()
      json.Description = res.xml.Description.text()
      json.Url = res.xml.Url.text()
      jsonMsgId = res.xml.MsgId.text()
    else if json.MsgType is "event"
      json.Event = res.xml.Event.text()
      if res.xml.EventKey
        json.EventKey = res.xml.EventKey.text() 
      else
        json.EventKey = ""
      json.Ticket = res.xml.Ticket.text() if res.xml.Ticket
    callback json
    return
  return

buildXml = (json, callback) ->
  #console.log("buildXml");
  xml = xmlbuilder.create("xml")
  xml.ele("ToUserName").dat json.FromUserName
  xml.ele("FromUserName").dat json.ToUserName
  xml.ele("CreateTime").dat json.CreateTime
  
  #xml.ele("MsgType").dat(json.MsgType);
  
  if json.MsgType is "text"
    isPreEvent json.FromUserName,(reply)->
      if reply
        console.log "reply"
        xml.ele("MsgType").dat "text"

        followerHandler.isCodeExists  json.Content,(_id)->
          if _id
            if _id!=json.FromUserName
                result = "暗号输入成功，获得积分50分"
                followerHandler.updateSuperior(json.FromUserName,_id)
            else
                result = "对不起，不能输入自己的暗号哦～"   
            xml.ele("Content").dat result
            callback xml
          else
              xml.ele("Content").dat "暗号不存在，请重新输入"
              callback xml
      else
        console.log "text"
        xml.ele("MsgType").dat "text"
        xml.ele("Content").dat "It's text message"
        callback xml
    return 
  else if json.MsgType is "image"
    # xml.ele("Image").ele("MediaId").dat(json.MediaId);
    # xml.ele("Content").dat "It's image message"

  else if json.MsgType is "voice"
    xml.ele("MsgType").dat "text"
    #xml.ele("Voice").ele("MediaId").dat(json.MediaId);
    unless json.Recognition is "undefined"
      xml.ele("Content").dat json.Recognition
    else
      xml.ele("Content").dat "It's voice message"
  else if json.MsgType is "video"
    xml.ele("MsgType").dat "text"
    # json.MediaId = res.xml.MediaId.text();
    # json.ThumbMediaId = res.xml.ThumbMediaId.text();
    #With Viedo,it must be get its Title,Description for sending xml
    xml.ele("Content").dat "It's video message"
  else if json.MsgType is "location"
    xml.ele("MsgType").dat "text"
    #do something for location bussiness logic
    xml.ele("Content").dat "It's location message"
  
  #do something for link bussiness logic
  else 
    xml.ele("MsgType").dat "text"
    xml.ele("Content").dat "It's link message"  if json.MsgType is "link"
  
  # console.log(xml);
  # decode qrcode
  if json.MsgType is "image"
    decodeQRcode json.PicUrl,(err,result)->
      if err
        xml.ele("MsgType").dat "text"
        xml.ele("Content").dat "It's image message"
        callback xml
      else
        xml.ele("MsgType").dat "news"
        buildNewsForQRCode(result,json,xml)
        # xml.ele("Content").dat "Detected QRCode, It's content : " + result;
        console.log xml.end(
          pretty: true
          indent: "  "
          newline: "\n"
        )
        callback xml
      return
    return
  xml.ele("MsgType").dat "text"
  callback xml
  return


# if  it's from QRCode，execute below method
# it's hard code for demo something
buildNewsForQRCode = (qrresult,json,xml)->
  xml.ele("ArticleCount",2)
  articles = xml.ele("Articles")
  item1 = articles.ele("item")
  item1.ele("Title").dat("小米3 移动3G(GSM/TD-SCDMA)16G版  ￥2199")
  item1.ele("Description").dat("小米3 移动3G(GSM/TD-SCDMA)16G版 白色 定制机 手机")
  item1.ele("PicUrl").dat("http://img1.icson.com/product/pic200/101/003/101-003-29355.jpg")     
  item1.ele("Url").dat("http://m.51buy.com/t/detail/index.html?pid=1617622&channelId=")   
  item2 = articles.ele("item")
  item2 .ele("Title").dat("小米2S 3G (CDMA2000/CDMA) 32G 电信版 ￥2199")
  item2 .ele("Description").dat("小米手机 2S 3G (CDMA2000/CDMA) 手机 16G 电信版 三清后三网通用，强悍配置，全新四核性价比之王！")
  item2 .ele("PicUrl").dat("http://img1.icson.com/product/pic200/21/026/21-026-10009.jpg")     
  item2 .ele("Url").dat("http://m.51buy.com/t/detail/index.html?pid=1266905&channelId=") 
  return 

#build event response that message is text
buildEvent = (json, callback) ->
  xml = xmlbuilder.create("xml")
  xml.ele("ToUserName").dat json.FromUserName
  xml.ele("FromUserName").dat json.ToUserName
  xml.ele("CreateTime").dat json.CreateTime

  if json.Event is "subscribe"
    xml.ele("MsgType").dat "text"
    xml.ele("Content").dat "谢谢关注众云测试平台"
  else if json.Event is "subscribe"
    xml.ele("MsgType").dat "text"
    xml.ele("Content").dat "希望再次关注众云测试平台"
  else if json.Event is "CLICK" or json.Event is "VIEW"
    #handle menu
    buildClickMenuEvent json,xml,callback
    # menuName = handleMenu(json.EventKey)
    # xml.ele("Content").dat "点击菜单 ：" + menuName
  else if json.Event is "SCAN" and json.Ticket
    buildScanEvent(json,xml,callback)
    return
  else 
    xml.ele("MsgType").dat "text"
    str = "event:" + json.Event + " - EventKey:" + json.EventKey + (" - Ticket :" + json.Ticket if json.Ticket)
    xml.ele("Content").dat  str
  # console.log "xml -> " + xml
  # callback xml
  return

buildClickMenuEvent = (json,xml,callback)->
  if json.EventKey=="V1001_MY_CODE"
      # aqquire follower's code
      followerHandler.getFollowerCode json.FromUserName,(code)->
        xml.ele("MsgType").dat "text"
        xml.ele("Content").dat "您的暗号 ：" + code
        console.log "code ->" + xml
        callback xml
        return
  else if json.EventKey == "V1002_INPUT_CODE"
    # save pre event for this user
    console.log "V1002_INPUT_CODE"
    savePreEvent("V1002_INPUT_CODE|"+json.FromUserName,new Date())
    xml.ele("MsgType").dat "text"
    xml.ele("Content").dat " 请输入暗号 "
    callback xml
  else
    # menuName = handleMenu(json.EventKey)
    xml.ele("MsgType").dat "text"
    xml.ele("Content").dat "点击菜单 ：" + json.EventKey
    callback xml
  return
  

# find pre-command from redis,if get it ,pass value to callback
isPreEvent = (user,callback)->
  console.log "isPreEvent"
  key = "V1002_INPUT_CODE|"+user
  if(key.indexOf("V1002_INPUT_CODE")>=0)
    console.log "isPreEvent " + key;
    getPreCommand(key,callback);
  else
    callback null
  return

# save pre command when click menu
savePreEvent = (key,message)->
  client = configInstance.getRedisClient()
  client.set(key,message)
  client.expire(key,60*3)

# get pre command when send code after click menu in 3 minutes
getPreCommand = (key,callback)->
  console.log "getPreCommand"
  client = configInstance.getRedisClient()
  client.get key,(err,reply)->
    # if it cannot be accquired,return null (means reply = null)
    console.log "client get " +reply
    callback reply

buildScanEvent = (json,xml,callback)->
  # first fetch qrcode by scene_id
  # view: qrcode_by_scene_id
  queryQrcode = {
    key:json.EventKey
  }
  dbConnection = configInstance.getDBConnection()
  service = new ArticleService(dbConnection)
  service.find "weixin/qrcode_by_scene_id",queryQrcode,(err,docs)->
    #console.log JSON.stringify docs
    qrcode_id = docs[0].id
    queryArticle = {
      key:qrcode_id
    }
    # second fetch articles by qrcode_id
    # view qrcode_articles
    service.find "weixin/qrcode_articles",queryArticle,(err,docs)->
      length = docs.length
      xml.ele("MsgType").dat "news"
      xml.ele("ArticleCount",length)
      articles = xml.ele("Articles")
      for item in docs
          element = articles.ele("item")
          element .ele("Title").dat(item.value.title)
          element .ele("Description").dat(item.value.description)
          element .ele("PicUrl").dat(item.value.picurl)     
          element .ele("Url").dat(item.value.url) 
      # console.log "xml -> " + xml
      callback xml

menuJson = button: [
  {
    type: "click"
    name: "众云查单"
    key: "V1001_TODAY_MUSIC"
  }
  {
    type: "click"
    name: "众云定位"
    key: "V1001_TODAY_SINGER"
  }
  {
    name: "菜单"
    sub_button: [
      {
        type: "view"
        name: "关于我们"
        url: "http://www.nuubiz.com/"
      }
      {
        type: "view"
        name: "打开系统"
        url: "http://www.nuubiz.com/"
      }
      {
        type: "click"
        name: "赞一下我们"
        key: "V1001_GOOD"
      }
    ]
  }
]
handleMenu = (key) ->
  button = menuJson.button
  i = 0

  while i < button.length
    if button[i].sub_button
      sub_button = button[i].sub_button
      j = 0

      while j < sub_button.length
        if sub_button[j].key isnt "undefined" and sub_button[j].key is key
          return sub_button[j].name
        else return sub_button[j].name  if sub_button[j].url isnt "undefined" and sub_button[j].url is key
        j++
    else if button[i].key isnt "undefined" and button[i].key is key
      return button[i].name
    else return button[i].name  if button[i].url isnt "undefined" and button[i].url is key
    i++
  return