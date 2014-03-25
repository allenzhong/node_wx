cradle = require 'cradle'

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

            #data model
            @Blog_Model = {
                    id: "",
                    belong_to_page_id: "",
                    belong_to_user_id: "",
                    title: "",
                    author: "",
                    content: "",
                    created: "",
                    tags: []
                }
            @User_Model = {
                    id: "",
                    name: "",
                    password: "",
                    hash: "",
                    email: ""
                }

            @AdminPageNum = 20
        getDBConnection:()->
            host = @CouchDB_URL
            port = @CouchDB_Port
            connection = new cradle.Connection host,port, {
                                cache: true,
                                raw:false}
            db = connection.database @CouchDB_Name
    @getInstance:()->
        instance ?= new Config()
        
module.exports = Configuration
