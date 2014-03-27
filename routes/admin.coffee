###################################################
##    Admin routers
###################################################
Configuration = require '../config/config'
Service = require '../service/Service'

UserModel = require '../model/user'
UserService = require '../service/UserService'


configInstance = Configuration.getInstance()
# BlogPageNum = configInstance.BlogPageNum
# LinkPageNum = configInstance.LinkPageNum
AdminPageNum = configInstance.AdminPageNum

# Init cradle connection from configuration
# dbConnection = configInstance.getDBConnection()


#########################################################
################### Admin #################################
#########################################################
#admin index page, show admin #console's description
exports.index = index = (req,res)->
    if req.session.user_id
        res.render 'admin/index'
    else
        res.render 'admin/login'

#Show login page
exports.login = login = (req,res)->
    res.render 'admin/login'

#Authenticate login information
exports.authenticate = authenticate = (req,res)->
    #console.log "authenticate"
    dbConnection = configInstance.getDBConnection()
    name = req.param("name")
    password = req.param("password")
    service = new UserService(dbConnection)
    service.authenticate name,password,(err,user)->
        if(err)
            #console.log err
            #handle login failed
            res.render 'admin/login'
        else
            #handle user sessions and redirect to index
            req.session.user_id = user.id
            req.session.user = user
            res.redirect '/admin/index'

#Logout
exports.logout = logout = (req,res)->
    req.session.destroy()
    res.redirect '/admin/index'

#########################################################
################### Admin  End  #############################
#########################################################

#It return a json for couchDB query parameters -> {limit:x,skip:y}
paging = (docs,page,countView,callback)->
    dbConnection = configInstance.getDBConnection()
    service = new Service(dbConnection)
    param = {limit:AdminPageNum,skip:(page-1)*AdminPageNum} 
    # #console.log JSON.stringify 
    service.count countView,(sum)->
            if sum%AdminPageNum == 0
                totalPages = sum/AdminPageNum
            else
                totalPages = sum/AdminPageNum+1
            callback {docs:docs,sum:sum,current:page,numberOfPages:parseInt(totalPages)}     

