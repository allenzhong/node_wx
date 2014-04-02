QRCodeModel = require '../model/qrcode'
Service = require './service'
request = require 'request'


class QRCodeService extends Service
    constructor:(@db)->
    parseDocs:(docs)->
       qrcodes = []
       for doc in docs
          code = new QRCodeModel()
          code.parseDoc doc
          qrcodes.push code
       return qrcodes


   #get code image from server by a qrcode object
   #callback buffer/imgPath
   getQRCodeImg:(obj,savePath,callback)->
   
module.exports = QRCodeService