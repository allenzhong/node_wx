crypto = require("crypto")
http = require("http")
https = require("https")
util = require("util")
xmlreader = require("xmlreader")
xmlbuilder = require("xmlbuilder")
xmlLib = require("xml")
message = require("../model/message")
user = require("../model/user")

#
# * GET home page.
# 
token = "allenzhong"
exports.index = (req, res) ->
  echostr = req.param("echostr")
  result = checkSignature(req)
  if result
    res.send echostr
  else
    res.send "false"
  return

exports.create_menu = (req, res) ->
  getAccessToken (token) ->
    console.log token
    createMenu token, (ress) ->
      resJson =
        msg: ress.responseText
        token: token

      res.send resJson
      return

    return

  return

exports.doMessage = (req, res) ->
  
  #console.log(req.rawBody);
  #res.send(req.rawBody);
  message.handleMsg req.rawBody, (xml) ->
    res.header "Content-Type", "text/xml"
    res.send xml.end(
      pretty: true
      indent: "  "
      newline: "\n"
    )
    return

  return


#get Followers list
exports.followers = (req, res) ->
  test = req.param("test")
  if test is "ultuum"
    getAccessToken (access_token) ->
      console.log "access token" + access_token
      user.getFollowers access_token, "", (json) ->
        res.render "followers", json
        return

      return

  else
    res.render "followers",
      test: "test"

  return


#user.getFollowers()

#get Single Follower
exports.follower = (req, res) ->
  open_id = req.param("id")
  getAccessToken (access_token) ->
    console.log "access token-> " + access_token
    user.getFollower access_token, open_id, (json) ->
      res.json json
      return

    return

  return

exports.sendMsg = (req, res) ->
  open_id = req.param("id")
  msg = req.param("content")
  getAccessToken (access_token) ->
    user.sendmsg access_token, open_id, "text", msg, (response) ->
      res.send success: true  if response.statusCode is "200"
      return

    return

  return


#Check Wei Xin Signature
checkSignature = (req) ->
  signature = req.param("signature")
  timestamp = req.param("timestamp")
  nonce = req.param("nonce")
  array = [
    token
    timestamp
    nonce
  ]
  
  # console.log(array);
  sortArray = array.sort()
  str = sortArray.join("")
  shasum = crypto.createHash("sha1")
  shasum.update str
  hex = shasum.digest("hex")
  
  # console.log("hex: " + hex);
  if signature is hex
    true
  else
    false

appID = "wxba50ad44bb9be2db"
appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25"
accessTokenUrl = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s"
createMenuUrl = " https://api.weixin.qq.com/cgi-bin/menu/create?access_token=%s"

#Get Access Token,GET
#callback(json)
# json: {
#     "access_token": "xxx", 
#     "expires_in": 7200
# }
getAccessToken = (callback) ->
  url = util.format(accessTokenUrl, appID, appsecrect)
  console.log "access url :" + url
  https.get url, (res) ->
    body = ""
    res.on "data", (d) ->
      body += d
      return

    res.on "end", ->
      console.log "body: " + body
      json = JSON.parse(body)
      callback json.access_token
      return

    return

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

#create menu,POST
createMenu = (token, callback) ->
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