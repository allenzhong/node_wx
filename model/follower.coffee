# Follower Model
# {
#     "subscribe": 1, 
#     "openid": "o6_bmjrPTlm6_2sgVt7hMZOPfL2M", 
#     "nickname": "Band", 
#     "sex": 1, 
#     "language": "zh_CN", 
#     "city": "广州", 
#     "province": "广东", 
#     "country": "中国", 
#     "headimgurl":    "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0", 
#    "subscribe_time": 1382694957
# }
class Follower
    constructor:(@id,@rev,@subscribe,@openid,@nickname,@sex,@language,@city,@province,@country,@headimgurl,@subscribe_time)->

    parseDoc:(doc)->
        @id = doc._id
        @rev = doc._rev
        @subscribe = doc.subscribe
        @openid = doc.openid
        @nickname = doc.nickname
        @sex = doc.sex
        @language = doc.language
        @city = doc.city
        @province = doc.province
        @country = doc.country
        @headimgurl = doc.headimgurl
        @subscribe_time = doc.subscribe_time
        @resource =  "follower"

    setObject:(obj)->
        @id = obj.id unless obj.id
        @rev = obj.rev unless obj.rev
        @subscribe = obj.subscribe
        @openid = obj.openid
        @nickname = obj.nickname
        @sex = obj.sex
        @language = obj.language
        @city = obj.city
        @province = obj.province
        @country = obj.country
        @headimgurl = obj.headimgurl
        @subscribe_time = obj.subscribe_time
        @resource = 'follower'
        return null

    getObject:->
        @follower = {
            subscribe:@subscribe,
            openid:@openid,
            nickname:@nickname,
            sex:@sex,
            language:@language,
            city:@city,
            province:@province,
            country:@country,
            headimgurl:@headimgurl,
            subscribe_time:@subscribe_time,
            resource :@resource
        }
        #`#console.log(""+ @id)
        @follower['_id']=@id if @id
        @follower['_rev']=@rev if@rev
        return @user



    module.exports = Follower