UserModel = require '../model/user'
Service = require './Service'

class UserService extends Service
    constructor:(@db)->

    parseDocs:(docs)->
        users = []
        for doc in docs
            user = new UserModel()
            user.parseDoc doc
            users.push user
        return users
    #need verify user name and email is not duplicated
    verify:(obj,callback)->
        #if it's not a user
        if obj.resource!='user'
            return false
        #then must define a general view that can find by name&email
        #!!!!!! how to resolve Async method,Thinking~~~~~~~~
        find 'blog/user_find_by_name_or_email',null,(docs)->


    # Authenticate user name and password 
    authenticate:(name,password,fn)->
        #console.log "new user " + name + " passwd: " + password
        docs = this.find 'blog/user_by_name',{ key: name },(docs)->
            #console.log "Get login docs ->" + JSON.stringify docs
            loginSuccess = false
            if docs
                loginUser = new UserModel()         
                loginUser.parseDoc(docs[0])   
                loginSuccess = loginUser.compare(password)
                if loginSuccess
                    fn(null,loginUser)
                else
                    fn(new Error('invalid user name or password'))
            else
                fn(new Error('invalid user name or password'))
module.exports = UserService