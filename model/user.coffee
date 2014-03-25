bcrypt = require 'bcrypt'

#User Model

class User

    constructor:(@id,@rev,@name,@password,@email)->

        #private method
        @hash=(password)->
            if(password)
                #console.log("Password : " + password)
                salt = bcrypt.genSaltSync 10
                #console.log("Salt : " + salt)
                hash = bcrypt.hashSync password, salt
                #console.log("hash : " + hash)
                return hash
            
        #belong to constructor method 
        @password = @hash(password)
        #console.log("My Password : " + @password)
        @resource = 'user'

    parseDoc:(doc)->
        @id = doc._id
        @name = doc.name
        @password = doc.password
        @email = doc.email
        @rev = doc._rev
        @resource =  "user"

    setObject:(obj)->
        @id = obj.id unless obj.id
        @rev = obj.rev unless obj.rev
        @name = obj.name
        @password = @hash(obj.password)
        @email = obj.email
        @resource = 'user'
        return null

    getObject:->
        @user = {
            name: @name,
            password: @password,
            email: @email,
            resource :@resource
        }
        #`#console.log(""+ @id)
        @user['_id']=@id if @id
        @user['_rev']=@rev if@rev
        return @user
    
    compare:(inputValue)->
        bcrypt.compareSync(inputValue,@password)

module.exports = User