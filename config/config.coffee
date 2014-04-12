cradle = require 'cradle'
redis = require 'redis'
#Configurations 
class Configuration
    instance = null

    class Config
        constructor:()->
            #db config
            @CouchDB_URL  = 'http://localhost'
            @CouchDB_Port = '5984'
            @CouchDB_Name = 'weixin'

            #auth
            @Auth_Hash = "Myhash"

            #PageNum
            @AdminPageNum = 20
            @redisClient = redis.createClient()
        getDBConnection:()->
            host = @CouchDB_URL
            port = @CouchDB_Port
            connection = new cradle.Connection host,port, {
                                cache: true,
                                raw:false}
            db = connection.database @CouchDB_Name

        getRedisClient:()->
            @redisClient
            
    @getInstance:()->
        instance ?= new Config()
        
module.exports = Configuration
