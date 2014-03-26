Configuration = require '../config/config'
# log4js = require 'log4js'
# logger = require('../config/logger').logger("service")

class Service
    constructor:(@db)->
        configInstance = Configuration.getInstance()
        unless @db
            @db = configInstance.getDBConnection()

            
    #Save object
    save:(obj,callback)->
        @db.save obj, callback

    #Find view
    find:(view,params,callback,returnKey,obj)->
        @db.view view,params, (err,res)->
            if(err)
                callback err
            else
                docs = []
                keys = [] if returnKey
                res.forEach (key,row)->
                    if returnKey
                        docs.push {key:key,value:row}
                    else
                        docs.push row
                if obj
                    callback docs,obj
                else 
                    callback docs
                return docs

    #Get Document by ids
    get:(ids,callback)->
        @db.get ids,callback

    #count 
    count:(countView,callback)->
        @db.view countView,{reduce:true}, (err,res)->
            if(err)
                callback err
            else
                sum = 0
                res.forEach (key,row)->
                    sum = sum + row
                #console.log sum
                callback sum
                return sum
    #Delete Document by ids
    delete:(id,rev,callback)->
        # logger.info("id:" + id + " rev:" +rev)
        if rev
            @db.remove id,rev,callback
        else
            @db.remove id,callback
            
    #test function          
    warnning:(obj)->
        #console.log("warnning id: " + obj.id)

module.exports  = Service