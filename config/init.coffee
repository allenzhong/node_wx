######################################################
## Initialization of Adiantum App
## With CouchDB, Create View of All data model
######################################################
#require components
Configuration = require './config'
UserModel = require '../model/user'
UserService = require '../service/userService'
BlogModel = require '../model/blog'
BlogService = require '../service/blogService'
#Get config singleton instance
configInstance = Configuration.getInstance()

# Init cradle connection from configuration
dbConnection = configInstance.getDBConnection()

dbConnection.exists (err,exists)->
    if err
        console.log 'error in exists'
    else if exists
        dbConnection.destroy ()->
            console.log 'Blog database is exists,and destroied'
            dbConnection.create ()->
                init dbConnection               
                return null
            return null     
    else
        console.log 'Blog db is not exsits'
        dbConnection.create ()->
                init dbConnection
                        
            console.log 'Created'
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
    welcomeBlog =  new BlogModel(null,null,"Welcome to Adiantum","Welcome to Adiantum Blog","admin",new Date(),"")
    blogService = new BlogService(dbConnection)
    objBlog = welcomeBlog.getObject()
    console.log objBlog
    blogService.save objBlog,(err,res)->
        if err
            console.log "Error in welcome blog Create"  
        else
            console.log "Welcome blog is created"
    #create user's view
    #1. all,byName,by
            designViews = [
                {
                    '_id':'_design/blog',
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
                        user_by_email:{
                            map:(doc)->
                                if(doc.resource=='user')
                                    return emit doc.email ,doc
                        },
                        user_by_name:{
                            map:(doc)->
                                if(doc.resource=='user')
                                    return emit doc.name ,doc
                        },
                        blog:{
                            map:(doc)->
                                if(doc.resource == 'blog')
                                    return emit doc._id,doc
                        },
                        count_blog:{
                            map:(doc)->
                                if(doc.resource=='blog')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                return sum(values)
                        },
                        link:{
                            map:(doc)->
                                if(doc.resource == 'link')
                                    return emit doc._id,doc
                        },
                        count_link:{
                            map:(doc)->
                                if(doc.resource=='link')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                return sum(values)
                        },              
                        album:{
                            map:(doc)->
                                if(doc.resource=='album')
                                    return emit doc._id ,doc
                        },
                        count_album:{
                            map:(doc)->
                                if(doc.resource=='album')
                                    return emit doc.id,1
                            reduce:(keys,values,rereduce)->
                                    return sum(values)
                        }
                    }
                }
             ]
            
            dbConnection.save designViews, (err,res)->
                if err 
                    console.log "Error in Create design views"
                else 
                    console.log "Successful create design views"






