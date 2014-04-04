
Service = require './service'

class ArticleService extends Service
    constructor:(@db)->


    find:(view,params,callback,returnKey,obj)->
        @db.view view,params, (err,res)->
            # console.log "Article res:->" + res
            if(err)
                callback err
            else
                callback null,res

module.exports = ArticleService