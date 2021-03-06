FollowerModel = require '../model/follower'
Service = require './service'

class FollowerService extends Service
    constructor:(@db)->
    parseDocs:(docs)->
       followers = []
       for doc in docs
          follower = new FollowerModel()
          follower.parseDoc doc
          followers.push follower
       return followers

module.exports = FollowerService