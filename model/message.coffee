#Message Model
class Message

    # @features includes every type's feature properties which is got from weixin server
    # eg.  image include PicUrl and MediaId,except Content etc.
    constructor:(@id,@rev,@ToUserName,@FromUserName,@CreateTime,@MsgType,@features)->
        this.defineProperty(@MsgType,@features)
        # after used features ,delete it.
        delete this["features"]
        console.log JSON.stringify this
        @resource =  "message"
    class Article
        constructor:(@Title,@Description,@PicUrl,@Url)->
    

    # create Inner class instance
    createArticle:(title,description,picurl,url)->
        article = new Article(title,description,picurl,url)
        return article
        # if(@Articles)

    # insert article to @Articles
    # force: if @Articles is not exists,create it 
    insertArticle:(article,force)->
        if(@Articles typeof Array)
            @Articles.push(article)
        else if(forceCreate)
            @Articles=[]
            @Articles.push(article)
        return

    defineProperty:(type,features)->
        if(type=="text")
            @Content = features.Content
        else if(type=="image")
            @PicUrl = features.PicUrl
            @MediaId = features.MediaId
        else if(type=="voice")
            @MediaId = features.MediaId
            @Format = features.Format
         else if(type=="video")
            @MediaId = features.MediaId
            @ThumbMediaId = features.ThumbMediaId           
         else if(type=="location")
            @Location_X = features.Location_X
            @Location_Y = features.Location_Y      
            @Scale = features.Scale
            @Label = features.Label
         else if(type=="link")
            @Title = features.Title
            @Description = features.Description      
            @Url = features.Url
            @MsgId = features.MsgId       
        else if(type=="news")
            @ArticleCount=features.ArticleCount
            @Articles = features.Articles



    parseDoc:(doc)->
        @id = doc._id
        @rev = doc._rev
        @ToUserName = doc.ToUserName
        @FromUserName = doc.FromUserName
        @CreateTime = doc.CreateTime
        @MsgType = doc.MsgType
        @MsgId  = doc.MsgId
        this.defineProperty(doc.MsgType,doc)
        @resource =  "message"
        return

    setObject:(obj)->
        @id = obj.id unless obj.id
        @rev = obj.rev unless obj.rev
        @ToUserName = doc.ToUserName
        @FromUserName = doc.CreateTime
        @CreateTime = doc.CreateTime
        @MsgType = doc.MsgType
        @MsgId  = doc.MsgId
        this.defineProperty(doc.MsgType,doc)
        @resource =  "message"
        return null

    getObject:->
        @message = {
            ToUserName:@ToUserName,
            FromUserName:@FromUserName,
            CreateTime:@CreateTime,
            MsgType:@MsgType,
            MsgId:@MsgId
            resource :"message"
        }
        @message['_id']=@id if @id
        @message['_rev']=@rev if@rev
        getProperty(@message)
        return this

    getProperty:(obj)->
        if(obj.MsgType=="text")
            obj['Content'] = @Content
        else if(obj.MsgType=="image")
            obj['PicUrl'] = @PicUrl
            obj['MediaId'] = @MediaId
        else if(obj.MsgType=="voice")
            obj['Format'] = @Format
            obj['MediaId'] = @MediaId
        else if(obj.MsgType=="video")
            obj['ThumbMediaId'] = @ThumbMediaId
            obj['MediaId'] = @MediaId
        else if(obj.MsgType=="location")
            obj['Location_X'] = @Location_X
            obj['Location_Y'] = @Location_Y
            obj['Scale'] = @Scale
            obj['Label'] = @Label
        else if(obj.MsgType=="link")
            obj['Title'] = @Title
            obj['Description'] = @Description
            obj['Url'] = @Url
            obj['MsgId'] = @MsgId  


module.exports = Message