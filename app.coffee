###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
routers = require './config/routers'
app = express()


# all environments
app.configure ()->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use(express.cookieParser('sctalk admin manager'))
  app.use(express.session())
  app.use (req,res,next)->
      res.locals.session = req.session
      next()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))
  # development only
  app.use express.errorHandler()  if "development" is app.get("env")
# routers
routers.routerSettings app
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return
