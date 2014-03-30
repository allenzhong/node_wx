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
    #Override Find view
    find:(view,params,callback,returnKey,obj)->
        @db.view view,params, (err,res)->
            # console.log "Message res:->" + res
            if(err)
                callback err
            else
                docs = []
                for item in res
                    docs.push(item)
                if obj
                    callback docs,obj
                else 
                    callback docs
                return docs

module.exports = MessageService