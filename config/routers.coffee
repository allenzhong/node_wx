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
    app.get "/admin/:module/:action/:id",adminfilter,doAdminAction
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


    app.get "/follower/:id", routes.follower
    app.get "/followers", routes.followers
    app.get "/sendMsg/:id", routes.sendMsg
    app.get "/createMenu", routes.create_menu
    app.get "/updateToken",routes.updateToken
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

    return