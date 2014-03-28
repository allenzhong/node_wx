#For recive message and send message with different types
xmlreader = require("xmlreader")
xmlbuilder = require("xmlbuilder")
Configuration = require '../config/config'
MessageModel = require "../model/message"
MessageService = require("../service/messageService")
#Get config singleton instance
configInstance = Configuration.getInstance()
#Handle Message,Return Json as Parameter to Callback method
#callback(sending xml)
exports.handleMsg = (xml, callback) ->
  readXml xml, (json) ->
    if json.MsgType is "event"
      console.log "it's event ->" + JSON.stringify(json)
      buildEvent json, callback
    else
      saveMessage(json)
      buildXml json, callback
    return

  return

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
      json.EventKey = res.xml.EventKey.text()  if json.Event is "CLICK" or json.Event is "VIEW"
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
  xml.ele("MsgType").dat "text"
  if json.MsgType is "text"
    xml.ele("Content").dat "It's text message"
  else if json.MsgType is "image"
    
    # xml.ele("Image").ele("MediaId").dat(json.MediaId);
    xml.ele("Content").dat "It's image message"
  else if json.MsgType is "voice"
    
    #xml.ele("Voice").ele("MediaId").dat(json.MediaId);
    unless json.Recognition is "undefined"
      xml.ele("Content").dat json.Recognition
    else
      xml.ele("Content").dat "It's voice message"
  else if json.MsgType is "video"
    
    # json.MediaId = res.xml.MediaId.text();
    # json.ThumbMediaId = res.xml.ThumbMediaId.text();
    #With Viedo,it must be get its Title,Description for sending xml
    xml.ele("Content").dat "It's video message"
  else if json.MsgType is "location"
    
    #do something for location bussiness logic
    xml.ele("Content").dat "It's location message"
  
  #do something for link bussiness logic
  else xml.ele("Content").dat "It's link message"  if json.MsgType is "link"
  
  #console.log(xml);
  callback xml
  return


#build event response that message is text
buildEvent = (json, callback) ->
  xml = xmlbuilder.create("xml")
  xml.ele("ToUserName").dat json.FromUserName
  xml.ele("FromUserName").dat json.ToUserName
  xml.ele("CreateTime").dat json.CreateTime
  xml.ele("MsgType").dat "text"
  if json.Event is "subscribe"
    xml.ele("Content").dat "谢谢关注众云测试平台"
  else if json.Event is "subscribe"
    xml.ele("Content").dat "希望再次关注众云测试平台"
  else if json.Event is "CLICK" or json.Event is "VIEW"
    
    #handle menu
    menuName = handleMenu(json.EventKey)
    xml.ele("Content").dat "点击菜单 ：" + menuName
  console.log "xml -> " + xml
  callback xml
  return

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