MessageModel = require '../model/message'
Service = require './service'

class MessageService extends Service
    constructor:(@db)->

    parseDocs:(docs)->
       messages = []
       for doc in docs
          msg = new MessageModel()
          msg.parseDoc doc
          messages.push msg
       return messages

module.exports = MessageService