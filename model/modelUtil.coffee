https = require 'https'

exports.getJson = (url,callback)->
	https.get url,(res)->
	    body = ""
	    res.on 'data',(d)->
	      body = body + d
	    res.on 'end',()->
	      console.log 'follower body ->' + body
	      json =  JSON.parse(body)
	      callback json
exports.postJson = (host,path,token,json,callback)->
    jsonString = JSON.stringify(json)
    headers = {
        'Content-Type': 'text/html;chartset=utf-8',
        'Content-Length': jsonString.length,
        'encoding': "utf-8"
    }
    options = {
        host: host,
        port: 443,
        path: path + token,
        method: "POST"
        # headers: headers
    }
    req = https.request options, (res)-> 
          console.log("res status :" + res.statusCode)
          res.on 'data', (chunk)->
              console.log("CreateMenuRes:" + chunk)
          
          if (typeof(callback) == "function")
              callback(res)
    
    console.log("jsonString:->" + jsonString)
    req.write(jsonString)
    req.end()