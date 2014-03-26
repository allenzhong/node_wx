# Follower Model
class ConfigurationModel

    constructor:(@id,@rev,@appid,@secret,@access_token,@expires_in,@token_created)->

    parseDoc:(doc)->
        @id = doc._id
        @rev = doc._rev
        @appid = doc.appid
        @secret = doc.secret
        @access_token = doc.access_token
        @expires_in = doc.expires_in
        @token_created = doc.token_created
        @resource =  "config"

    setObject:(obj)->
        @id = obj.id unless obj.id
        @rev = obj.rev unless obj.rev
        @appid = obj.appid unless obj.appid
        @secret = obj.secret unless obj.secret
        @access_token = obj.access_token unless obj.access_token
        @expires_in = obj.expires_in unless obj.expires_in
        @token_created = obj.token_created unless obj.token_created
        @resource = 'config'
        return null

    getObject:->
        @config = {
            resource:'config'
        }
        #`#console.log(""+ @id)
        @config['_id'] = @id if @id
        @config['_rev'] = @rev if@rev
        @config['appid'] = @appid if @appid
        @config['secret'] = @secret if @secret
        @config['access_token'] = @access_token if @access_token
        @config['expires_in'] = @expires_in if @expires_in
        @config['token_created'] = @token_created if @token_created

        return @config


    # created : unix timestamp
    # comparetor: unix timestamp
    # expires_in: default in weixin is 7200
    isExpired:(created,comparetor,expires_in=7200)->
        result = false
        offset = comparetor - created
        result = true if offset>=7200
        return result


module.exports = ConfigurationModel