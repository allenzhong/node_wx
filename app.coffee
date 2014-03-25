###
Module dependencies.
###
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")
app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")

# app.use(function(req, res, next) {
#     var data = '';
#     req.setEncoding('utf8');
#     req.on('data', function(chunk) {
#         console.log("data : " + chunk);
#         data += chunk;
#     });
#     req.on('end', function() {
#         req.rawBody = data;
#         console.log(" req.rawBody : " + req.rawBody);
#         next();
#     });
# });
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/follower/:id", routes.follower
app.get "/followers", routes.followers
app.get "/sendMsg/:id", routes.sendMsg
app.get "/createMenu", routes.create_menu
app.post "/", (req, res, next) ->
  data = ""
  req.setEncoding "utf8"
  req.on "data", (chunk) ->
    
    #console.log("data : " + chunk);
    data += chunk
    return

  req.on "end", ->
    req.rawBody = data
    
    #console.log(" req.rawBody : " + req.rawBody);
    routes.doMessage req, res
    return

  return

app.get "/users", user.list
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return
