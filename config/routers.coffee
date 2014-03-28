routes = require '../routes/index'
# routesUser  = require '../routes/user'
routesAdmin = require '../routes/admin'

adminfilter = (req,res,next)->
    # logger.info "filter "+ req.url
    unless(req.session.user_id)
        res.redirect '/admin'
        #res.render "admin/login"
    else
        next()

doAdminAction = (req,res,next)->
    module = req.params.module
    action = req.params.action
    console.log "module " + module + " action " + action
    if(module==undefined && action!=undefined)
        routesAdmin[action](req,res,next)
    else if (module!=undefined && action!=undefined)
        routesAdmin[module+'_'+action](req,res,next)
    else
        res.status(404)
        res.end

exports.routerSettings = (app)->

    #admin filters of routes
    app.get "/admin/:action",adminfilter,doAdminAction
    app.get "/admin/:module/:action",adminfilter,doAdminAction
    app.get "/admin/:module/:action/:id(^\d{1,10})$",adminfilter,doAdminAction
    app.post "/admin/:module/:action/:id",adminfilter,doAdminAction
    app.get "/admin/:module/:action/:type",adminfilter,doAdminAction
    app.get "/admin/:module/:action/:type/:id(^\d{1,10})$",adminfilter,doAdminAction
    #admin routes
    app.get "/admin", routesAdmin.index
    app.get "/admin/index",routesAdmin.index
    app.get "/admin/login",routesAdmin.login
    app.get "/admin/logout",routesAdmin.logout
    app.post "/admin/authenticate",routesAdmin.authenticate

    #admin follower
    app.get "/admin/follower/index/:id",routesAdmin.follower_index
    app.get "/admin/follower/fresh",routesAdmin.follower_fresh
    app.get "/admin/follower/update/:id",routesAdmin.follower_update
    app.get "/admin/follower/sendMsg/:id", routesAdmin.follower_sendMsg

    #admin user routes
    app.get "/admin/user/index/:id",routesAdmin.user_index
    app.get "/admin/user/add",routesAdmin.user_add
    app.post "/admin/user/save",routesAdmin.user_save
    app.get "/admin/user/show/:id",routesAdmin.user_show
    app.get "/admin/user/update/:id", routesAdmin.user_update
    app.del "/admin/user/delete/:id",routesAdmin.user_delete

    #admin config routes
    app.get "/admin/config/index",routesAdmin.config_index
    app.get "/admin/config/updateToken",routesAdmin.config_updateToken
    app.post "/admin/config/save",routesAdmin.config_save

    #admin message routes
    app.get '/admin/message/type/:type/:id',routesAdmin.message_type
    app.get '/admin/message/index/:id(\d*)',routesAdmin.message_index


    #Core message routes
    app.post "/", (req, res, next) ->
      data = ""
      req.setEncoding "utf8"
      req.on "data", (chunk) ->
        #console.log("data : " + chunk);
        data += chunk
        return
      req.on "end", ->
        req.rawBody = data
        routes.doMessage req, res
        return

    #deprecated routes
    app.get "/follower/:id", routes.follower
    app.get "/followers", routes.followers
    app.get "/sendMsg/:id", routes.sendMsg
    app.get "/createMenu", routes.create_menu
    app.get "/updateToken",routes.updateToken
    
    return