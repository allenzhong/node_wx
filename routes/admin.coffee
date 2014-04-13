###################################################
##    Admin routers
###################################################
Configuration = require '../config/config'
Service = require '../service/service'

QRCodeService = require '../service/qrcodeService'
QRCodeModel = require "../model/qrcode"
ConfigModel = require '../model/configuration'
ConfigurationService = require '../service/configurationService'
MessageModel = require '../model/message'
MessageService = require '../service/messageService'
UserModel = require '../model/user'
UserService = require '../service/userService'
FollowerModel = require '../model/follower'
FollowerService = require '../service/followerService'
followerHandler = require("../handler/follower")
platformHandler = require("../handler/platform")
qrcodeHandler = require("../handler/qrcode")

configInstance = Configuration.getInstance()
# BlogPageNum = configInstance.BlogPageNum
# LinkPageNum = configInstance.LinkPageNum
AdminPageNum = configInstance.AdminPageNum

# Init cradle connection from configuration
# dbConnection = configInstance.getDBConnection()


#########################################################
################### Admin #################################
#########################################################
#admin index page, show admin ##console's description
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
    ##console.log "authenticate"
    dbConnection = configInstance.getDBConnection()
    name = req.param("name")
    password = req.param("password")
    service = new UserService(dbConnection)
    service.authenticate name,password,(err,user)->
        if(err)
            ##console.log err
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
    # ##console.log JSON.stringify 
    service.count countView,(sum)->
        if sum%AdminPageNum == 0
            totalPages = sum/AdminPageNum
        else
            totalPages = sum/AdminPageNum+1
        callback {docs:docs,sum:sum,current:page,numberOfPages:parseInt(totalPages)}     



#########################################################
###################  Followers  ##############################
#########################################################
#get Followers list
exports.follower_index = follower_index = (req, res) ->
    #console.log "Enter index"
    page = 1
    if req.params.id
        page = parseInt(req.params.id)
    dbConnection = configInstance.getDBConnection()
    service = new FollowerService(dbConnection)
    param = {limit:AdminPageNum,skip:(page-1)*AdminPageNum} 
    #console.log JSON.stringify param
    docs = service.find 'weixin/follower',param,(docs)->
        #console.log "docs - >"+JSON.stringify(docs)
        followers = service.parseDocs(docs)
        str = JSON.stringify docs
        #console.log "Enter index + " +  str
        paging followers,page,'weixin/count_follower',(json)->
            #console.log "page index + " +  JSON.stringify json
            res.render 'admin/follower/index' , json

# follower fresh and back to follower_index
exports.follower_fresh = follower_fresh = (req,res)->
    platformHandler.getAccessToken (access_token) ->
      # #console.log "access token" + access_token
      # res.render "followers"
      followerHandler.countFollowers (sum)->
          followerHandler.getFollowers access_token, "", (json) ->
            # #console.log json.data
            followerHandler.saveFollowersOpenId json
            res.json({redirect:"/admin/follower/index"})


#Update single follower
exports.follower_update = (req,res)->  
    open_id = req.params.id
    platformHandler.getAccessToken (access_token) ->
          followerHandler.getFollower access_token, open_id, (json)->
            followerHandler.saveFollowerFullInfo json
            res.json({redirect:"/admin/follower/index"})

# Send msg to user
exports.follower_sendMsg = (req, res) ->
  open_id = req.param("id")
  msg = req.param("content")
  platform.getAccessToken (access_token) ->
    user.sendmsg access_token, open_id, "text", msg, (response) ->
      # #console.log "statusCode ->" +response.statusCode
      res.send success: true  if response.statusCode == 200  

exports.follower_superior = (req,res)->
    id = req.param("id")
    dbConnection = configInstance.getDBConnection()
    service = new FollowerService(dbConnection)
    console.log  "id->" + id
    param = { key:id }
    service.find "weixin/follower_by_superior",param,(docs)->
        console.log docs
        res.render 'admin/follower/org',{openid:id,docs:docs}

exports.follower_orgmap = (req,res)->
    id = req.param("id")
    dbConnection = configInstance.getDBConnection()
    service = new FollowerService(dbConnection)
    console.log  "id->" + id
    param = { key:id }
    service.get id,(err,root)->
        console.log root
        service.find "weixin/follower_by_superior",param,(docs)->
            console.log docs
            json =     
                id: root._id,
                name: "<div class='orgchartnode'>"+root.nickname+"</div>",
                data: {
                    headimgurl:root.headimgurl
                },
                children:[]
            for item in docs
                child = 
                    id: item._id,
                    name: "<div class='orgchartnode'>"+item.nickname+"</div>",
                    data: {
                        headimgurl:item.headimgurl
                    },
                    children:[]
                json.children.push(child)
            res.send json



exports.follower_org = (req,res)->
    res.render 'admin/follower/org'


#########################################################
################### Admin  User   #############################
#########################################################
## index ##
# index page: show user list,comment list,and add/delete/update user func buttons
# And Some system func menus
exports.user_index = user_index = (req,res)->
    page = 1
    if req.params.id
        page = parseInt(req.params.id)
    param = {limit:AdminPageNum,skip:(page-1)*AdminPageNum} 
    #logger.info("entering admin index page")
    dbConnection = configInstance.getDBConnection()
    service = new UserService(dbConnection)
    docs = service.find 'weixin/user',param ,(docs)->
        #console.log "docs - >"+JSON.stringify(docs)
        users = service.parseDocs(docs)
        paging users,page,'weixin/count_user',(json)->
            res.render 'admin/user/index' , json     

#Show Add Post Page
exports.user_add = user_add = (req,res)->
    ##console.log "Add Post"
    res.render 'admin/user/add' 

#Show Update User Page
exports.user_update = user_update = (req,res)->
    ##console.log "show user"
    dbConnection = configInstance.getDBConnection()
    service = new UserService(dbConnection)
    query_id = req.param('id')
    service.get query_id, (err,doc)->
        res.render 'admin/user/update',{user:doc}

#Save Post
exports.user_save = user_savePost = (req,res)->

    if(req.param('id'))
        ##console.log "update user"
        welcomeUser = new UserModel(req.param('id'),req.param('rev'),req.param('name'),req.param('password'),req.param('email'))
    else
        ##console.log "new user"
        welcomeUser =  new UserModel(null,null,req.param('name'),req.param('password'),req.param('email'))
    dbConnection = configInstance.getDBConnection()
    service = new UserService(dbConnection)
    objUser = welcomeUser.getObject()
    service.save objUser,(err,ress)->
        if err
            ##console.log "Error in welcome user Create"  
        else
            res.redirect "admin/user/index"

#Show user page
exports.user_show = user_show = (req,res)->
    ##console.log "show user"
    dbConnection = configInstance.getDBConnection()
    service = new UserService(dbConnection)
    query_id = req.param('id')
    service.get query_id, (err,doc)->
        if doc.resource=='user'
            res.render 'admin/user/show',{user:doc}
        else
            res.render '404',{url:req.url}
#Delete user
exports.user_delete = user_delete = (req,res)->
    #logger.info("delete id:"+req.params["id"]+" rev:" +req.param("rev"))
    dbConnection = configInstance.getDBConnection()
    service = new BlogService(dbConnection)
    delete_id = req.param('id')
    delete_rev = req.param("rev")
    service.delete delete_id,delete_rev,(err,rs)->
        if(err)
            #logger.info(err)
            res.json({msg:err.error + " : " + err.reason})
#########################################################
################### Admin  User  End##########################
######################################################### 

#########################################################
################### Admin  Config  ###########################
######################################################### 
# Index Config, Show Configurations List
exports.config_index = (req,res)->
    dbConnection = configInstance.getDBConnection()
    service = new ConfigurationService(dbConnection)
    service.check (config)->
        res.render "admin/config/index",{config:config}

# update Token and redirect to admin/config/index
exports.config_updateToken = (req,res)->
    platformHandler.requestAndUpdateAccessToken () ->
        res.json({redirect:"/admin/config/index/"})

# save Config , now just save appid and secret
exports.config_save = (req,res)->
    appid = req.param("appid")
    secret = req.param("secret")
    #console.log "appid:->" + appid
    #console.log "secret:->" + secret
    dbConnection = configInstance.getDBConnection()
    service = new ConfigurationService(dbConnection)
    service.check (config)->
        config.appid = appid
        config.secret = secret
        # #console.log "Object -> " + JSON.stringify(config.getObject())
        service.save config.getObject(),(err,ress)->
            res.redirect "/admin/config/index/"
    return

#########################################################
################### Admin  Config  End# #######################
######################################################### 

#########################################################
################### Admin  Message  ##########################
######################################################### 
exports.message_index = message_index = (req,res)->
    #console.log "Index page"
    # get type
    type = req.params.type
    # #console.log type
    page = 1
    if req.params.id
        page = parseInt(req.params.id)
    param = {
            limit:AdminPageNum,
            skip:(page-1)*AdminPageNum,
            include_docs:true
    } 
    # logger.info("entering admin index page")
    dbConnection = configInstance.getDBConnection()
    service = new MessageService(dbConnection)
    docs = service.find 'weixin/message',param ,(docs)->
        # console.log "docs - >"+JSON.stringify(docs)    
        paging docs,page,'weixin/count_message',(json)->
            res.render 'admin/message/index' , json     

exports.message_type = message_type = (req,res)->
    # #console.log req.param("type")
    unless req.params.type
        message_index(req,res)
        return
    else
        type = req.params.type
    page = 1
    if req.params.id
        page = parseInt(req.params.id)
    # #console.log page    
    param = {
            limit:AdminPageNum,
            skip:(page-1)*AdminPageNum,
            include_docs:true
    } 
    #logger.info("entering admin index page")
    dbConnection = configInstance.getDBConnection()
    service = new MessageService(dbConnection)
    docs = service.find 'weixin/message_'+type,param ,(docs)->
        #console.log "docs - >"+JSON.stringify(docs)     
        paging docs,page,'weixin/count_message_'+type,(json)->
            json['type'] = type
            res.render 'admin/message/'+type+"Msg" , json     

#########################################################
################### Admin  Message  End #######################
######################################################### 



#########################################################
################### Admin  QRCode  ##########################
######################################################### 

exports.qrcode_index = (req,res)->
    page = 1
    if req.params.id
        page = parseInt(req.params.id)
    param = {limit:AdminPageNum,skip:(page-1)*AdminPageNum} 
    #logger.info("entering admin index page")
    dbConnection = configInstance.getDBConnection()
    service = new QRCodeService(dbConnection)
    docs = service.find 'weixin/qrcode',param ,(docs)->
        #console.log "docs - >"+JSON.stringify(docs)
        users = service.parseDocs(docs)
        paging users,page,'weixin/count_qrcode',(json)->
            res.render 'admin/qrcode/index' , json  


#Show Add qrcode Page
exports.qrcode_add = (req,res)->
    ##console.log "Add Post"
    res.render 'admin/qrcode/add' 

#Save QRCode
exports.qrcode_save = qrcode_save = (req,res)->
    type = req.param("type")
    console.log type
    scene_id = req.param("scene_id")
    description = req.param("description")

    platformHandler.getAccessToken (token)->
        # Request qrcode ticket
        if(type=="t")
            qrcodeHandler.requestTempCode scene_id,1800,token,(body)->
                #save pic and save object to db
                filename = "/images/"+qrcodeHandler.savePic(body.ticket)
                #console.log body.ticket
                save_qrcode_and_direct(req,res,body.ticket,filename,1800)
                return
        else
            qrcodeHandler.requestPermanetCode scene_id,token,(body)->
                #save pic and save object to db
                filename = "/images/"+qrcodeHandler.savePic(body.ticket)
                # console.log "requestPermanetCode-> " + body.ticket
                save_qrcode_and_direct(req,res,body.ticket,filename,-1)
                return
        return
    return
# save qrcode model and direct to index
save_qrcode_and_direct=(req,res,ticket,filename,expire_in=1800)->
    console.log  "description" +  req.param("description")
    scene_id = req.param("scene_id")
    description = req.param("description")
    if(req.param('id'))
        ##console.log "update qrcode"
        qrcode = new QRCodeModel(req.param('id'),req.param('rev'),scene_id,ticket,expire_in,filename,description)
    else
        ##console.log "new qrcode"
        qrcode = new QRCodeModel(req.param('id'),req.param('rev'),scene_id,ticket,expire_in,filename,description)
    
    dbConnection = configInstance.getDBConnection()
    service = new QRCodeService(dbConnection)
    objUser = qrcode.getObject()
    service.save objUser,(err,ress)->
        if err
            ##console.log "Error in  qrcode Create"  
        else
            res.redirect "admin/qrcode/index"

exports.qrcode_fetchArticles = (req,res)->
    qrcode_id = req.param "id"
    dbConnection = configInstance.getDBConnection()
    service = new Service(dbConnection)
    query = {
        key:qrcode_id
    }
    service.find "weixin/qrcode_articles",query,(docs)->
        console.log JSON.stringify docs
        res.json {articles:docs}
            
# Add Article to qrcode
exports.qrcode_addArticle = (req,res)->
    title = req.param "title"
    description = req.param "description"
    picurl = req.param "picurl"
    url = req.param "url"
    qrcode_id = req.param "id"
    article = {
        qrcode_id:qrcode_id,
        title:title,
        description:description,
        picurl:picurl,
        url:url,
        resource:"qrcode_article"
    }
    console.log JSON.stringify article
    dbConnection = configInstance.getDBConnection()
    service = new Service(dbConnection)
    service.save article, (err,ress)->
        if err
            console.log err.message
            res.json {success:false}
        else
            res.json {success:true}

#Remove a article from qrcode
exports.qrcode_delArticle = (req,res)->
    id = req.param "id"
    dbConnection = configInstance.getDBConnection()
    service = new Service(dbConnection)
    service.delete id,null,(err)->
        if err
            res.json {success:false}
        else
            res.json {success:true}
