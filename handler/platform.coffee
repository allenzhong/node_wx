crypto = require("crypto")
http = require("http")
https = require("https")
util = require("util")
xmlreader = require("xmlreader")
xmlbuilder = require("xmlbuilder")
xmlLib = require("xml")
moment = require 'moment'
Configuration = require '../config/config'
ConfigModel = require '../model/configuration'
ConfigurationService = require '../service/configurationService'



#Check Wei Xin Signature
exports.checkSignature = (req) ->
  signature = req.param("signature")
  timestamp = req.param("timestamp")
  nonce = req.param("nonce")
  array = [token,timestamp,nonce]
  # console.log(array);
  sortArray = array.sort()
  str = sortArray.join("")
  shasum = crypto.createHash("sha1")
  shasum.update str
  hex = shasum.digest("hex")
  # console.log("hex: " + hex);
  if signature is hex
    return true
  else
    return false


appID = "wxba50ad44bb9be2db"
appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25"
accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s"
createMenuUrl = " https://api.weixin.qq.com/cgi-bin/menu/create?access_token=%s"

#Get Access Token,GET
#callback(token)
exports.getAccessToken = (callback) ->
  # check wheather access_token is exists or expired
  #Get config singleton instance
  configInstance = Configuration.getInstance()
  # Init cradle connection from configuration
  db = configInstance.getDBConnection()
  service = new ConfigurationService(db)
  service.check (config)->
    available = isAccessTokenAvailable(config)
    if available
      callback config.access_token
    else
      requestAndUpdateAccessToken(callback);



# Request access token from server and save/update it
exports.requestAndUpdateAccessToken = (callback)->
  url = util.format(accessTokenUrl, appID, appsecrect)
  console.log "access url :" + url
  https.get url, (res) ->
    body = ""
    res.on "data", (d) ->
      body += d

    res.on "end", ->
      console.log "body: " + body
      json = JSON.parse(body)
      if !isErrorInAccessToken(json)
        saveAccessToken(json)
      callback json.access_token

# If errcode is exists, return true
isErrorInAccessToken = (responseJson)->
  if responseJson.errcode?
    return true
  else 
    return false


# Wheather  access token is saved in couchDB or expired 
isAccessTokenAvailable = (config)->
  if config.access_token?
    access_token = config.access_token 
    now = new moment().unix()
    expires_in = config.expires_in
    token_created = config.token_created
    isExpired = config.isExpired token_created,now,expires_in
    return !isExpired
  else
    return false;

# Save/update access token in DB
saveAccessToken = (json)->
  db = configInstance.getDBConnection()
  service = new ConfigurationService(db)
  service.check (config)->
    config.access_token = json.access_token
    config.expires_in = json.expires_in
    config.token_created = new moment().unix()
    service.save config.getObject(),null,(err)->
      if err
        console.log "Save token error"
      else
        return

#create menu,POST
exports.createMenu = (token, callback) ->
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
  url = util.format(createMenuUrl, token)
  console.log "menu url:-> " + url
  jsonString = JSON.stringify(menuJson)
  console.log "json length", jsonString.length
  headers =
    "Content-Type": "text/html;chartset=utf-8"
    "Content-Length": jsonString.length
    encoding: "utf-8"

  options =
    host: "api.weixin.qq.com"
    port: 443
    path: "/cgi-bin/menu/create?access_token=" + token
    method: "POST"

  
  #headers: headers
  req = https.request(options, (res) ->
    console.log "res status :" + res.statusCode
    res.on "data", (chunk) ->
      console.log "CreateMenuRes:" + chunk
      return

    callback res  if typeof (callback) is "function"
    return
  )
  console.log "jsonString:->" + jsonString
  req.write jsonString
  req.end()
  return