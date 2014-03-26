######################################################
## Initialization of Adiantum App
## With CouchDB, Create View of All data model
######################################################
#require components
Configuration = require './config'
UserModel = require '../model/user'
UserService = require '../service/userService'
ConfigModel = require '../model/configuration'
ConfigurationService = require '../service/configurationService'
#Get config singleton instance
configInstance = Configuration.getInstance()

# Init cradle connection from configuration
dbConnection = configInstance.getDBConnection()

dbConnection.exists (err,exists)->
    if err
        console.log 'error in exists'
    else if exists
        dbConnection.destroy ()->
            console.log 'weixin database is exists,and destroied'
            dbConnection.create ()->
                init dbConnection               
                return null
            return null     
    else
        console.log 'weixin db is not exsits'
        dbConnection.create ()->
                init dbConnection
            # console.log 'Created'
            #dosomething db

init = (dbConnection)->
    #Create Admin User And User's View
    adminUser = new UserModel(null,null,'admin','admin','zhong.allen@gmail.com')
    #save admin user
    userService = new UserService(dbConnection)
    obj = adminUser.getObject()
    console.log obj
    userService.save obj,(err,res)->
        if err
            console.log "Error in admin is be creating"
        else
            console.log "Admin is created"

    testUser = new UserModel(null,null,'test','test','test@gmail.com')
    obj = testUser.getObject()
    console.log obj
    userService.save obj,(err,res)->
        if err
            console.log "Error in test is be creating"
        else
            console.log "test is created"
    appID = "wxba50ad44bb9be2db"
    appsecrect = "1e46b3602cd99f55154bcb8d1a8b1b25"

    firstConfig =  new ConfigModel(null,null,appID,appsecrect,null,null,null)

    configService = new ConfigurationService(dbConnection)
    objConfig = firstConfig.getObject()
    console.log objConfig
    configService.save objConfig,(err,res)->
        if err
            console.log "Error in init Configuration Creating"  
        else
            console.log "Init Configuration Successful"
            # create design views
            designViews = [
                {
                    '_id':'_design/weixin',
                    views:{
                        #user's views
                        user:{
                            map:(doc)->
                                if(doc.resource=='user')
                                    return emit doc._id ,doc
                        },
                        count_user:{
                            map:(doc)->
                                if(doc.resource=='user')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                return sum(values)
                        },
                        config:{
                            map:(doc)->
                                if(doc.resource == 'config')
                                    return emit doc._id,doc
                        },
                        count_config:{
                            map:(doc)->
                                if(doc.resource=='config')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                return sum(values)
                        },
                        follower:{
                            map:(doc)->
                                if(doc.resource == 'follower')
                                    return emit doc._id,doc
                        },
                        count_follower:{
                            map:(doc)->
                                if(doc.resource=='follower')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                return sum(values)
                        },              
                        follower_by_openid:{
                            map:(doc)->
                                if(doc.resource=='follower')
                                    return emit doc.openid ,doc
                        },
                        follower_by_nickname:{
                            map:(doc)->
                                if(doc.resource=='follower')
                                    return emit doc.nickname ,doc
                        }
                    }
                }
             ]
            
            dbConnection.save designViews, (err,res)->
                if err 
                    console.log "Error in Create design views"
                else 
                    configService.check (config)->
                        console.log JSON.stringify(config)
                    console.log "Successful create design views"






