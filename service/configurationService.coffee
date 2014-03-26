ConfigurationModel = require '../model/configuration'
Service = require './Service'

class ConfigurationService extends Service
    constructor:(@db)->

    parseDocs:(docs)->
       configurations = []
       for doc in docs
          configuration = new ConfigurationModel()
          configuration.parseDoc doc
          configurations.push configuration
       return configurations

    # Check configuration is Exsits
    # callback(1 config record | null)
    check:(callback)->
        this.find "weixin/config",null,((docs,obj)->
            configs = obj.parseDocs docs
            # console.log configs.length
            if(configs.length>0)
                console.log  "In Length >0 :    "+JSON.stringify(configs[0])
                callback configs[0]
            else
                console.log "In Length ==0:   " 
                callback null),false,this

module.exports = ConfigurationService