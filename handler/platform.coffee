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
token = "allenzhong"
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

configInstance = Configuration.getInstance()

# get sysconfig object
# callback(config)
sysconfig = (callback)->
  db = configInstance.getDBConnection()
  service = new ConfigurationService(db)
  service.check (config)->
    callback config


appID = "wxba50ad44bb9be2db"
appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25"
accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s"
createMenuUrl = " https://api.weixin.qq.com/cgi-bin/menu/create?access_token=%s"


#Get Access Token,GET
#callback(token)
exports.getAccessToken = (callback) ->
  # check wheather access_token is exists or expired
  #Get config singleton instance
  
  # Init cradle connection from configuration
  db = configInstance.getDBConnection()
  service = new ConfigurationService(db)
  service.check (config)->
    available = isAccessTokenAvailable(config)
    console.log "Access Token is available:->" + available
    if available
      console.log "From Db get toke : " + config.access_token
      callback config.access_token
    else
      requestAndUpdateAccessToken(callback);
      # callback "4rC-ik7TPl2Iy53mgc2aBg8Vnlr-2iW_I9Cp8kqe38uUpqaAiKYgdxyaurXF9AAm7Gz6XwWSm4DV6T1WPzpRy44V8BFSJyn_eqEPDG4___UPhfDgQlvtv9eVLOBocOfRDS-q-oiPIILJOK6sbgfoFg"



# Request access token from server and save/update it
exports.requestAndUpdateAccessToken=requestAndUpdateAccessToken = (callback)->
  sysconfig (config)->
    console.log config.appid + " : " + config.secret
    url = util.format(accessTokenUrl, config.appid, config.secret)
    console.log "access url :" + url
    # json = {
    #   access_token:"4rC-ik7TPl2Iy53mgc2aBg8Vnlr-2iW_I9Cp8kqe38uUpqaAiKYgdxyaurXF9AAm7Gz6XwWSm4DV6T1WPzpRy44V8BFSJyn_eqEPDG4___UPhfDgQlvtv9eVLOBocOfRDS-q-oiPIILJOK6sbgfoFg",
    #   expires_in:7200
    # }
    # if !isErrorInAccessToken(json)
    #       console.log "Save token :" + json
    #       saveAccessToken(json)
    # console.log "From Server get toke :-> " + json.access_token
    # callback json.access_token
    https.get url, (res) ->
      body = ""
      res.on "data", (d) ->
        body += d
      res.on "end", ->
        console.log "body: " + body
        json = JSON.parse(body)
        if !isErrorInAccessToken(json)
          console.log "Save token :" + body
          saveAccessToken(json)
        console.log "From Server get toke :-> " + json.access_token
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
  console.log "Check"
  service.check (config)->
    console.log "check callback"
    config.access_token = json.access_token
    config.expires_in = json.expires_in
    config.token_created = new moment().unix()
    console.log "config object" + JSON.stringify(config.getObject())
    obj = config.getObject()
    console.log obj
    service.save obj,(err)->
      if err
        console.log "Save token error"


#create menu,POST
exports.createMenu = (token, callback) ->
  menuJson = 
      button: [{
          type: "click",
          name: "我的暗号",
          key: "V1001_MY_CODE"
          },
          {
          type: "click",
          name: "众云定位",
          key: "V1001_TODAY_SINGER"
          }
      ]
    
  jsonString = JSON.stringify(menuJson)
  options =
    host: "api.weixin.qq.com"
    port: 443
    path: "/cgi-bin/menu/create?access_token=" + token
    method: "POST"
  #headers: headers
  req = https.request options, (res) ->
    console.log "res status :" + res.statusCode
    res.on "data", (chunk) ->
      console.log "CreateMenuRes:" + chunk
      return
    callback res  if typeof (callback) is "function"
  console.log "jsonString:->" + jsonString
  req.write jsonString
  req.end()
