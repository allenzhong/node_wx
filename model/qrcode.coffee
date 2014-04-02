class QRCode
  
  constructor:(@id,@rev,@scene_id,@ticket,@expire_seconds,@img_path,@description)->

  parseDoc:(doc)->
      @id = doc._id
      @rev = doc._rev
      @scene_id = doc.scene_id
      @ticket = doc.ticket
      @expire_seconds = doc.expire_seconds
      @img_path = doc.img_path
      @description = doc.description
      @resource =  "qrcode"

  setObject:(obj)->
      @id = obj.id unless obj.id
      @rev = obj.rev unless obj.rev
      @scene_id = obj.scene_id
      @ticket = obj.ticket
      @expire_seconds = obj.expire_seconds unless obj.expire_seconds
      @img_path = obj.img_path
      @description = obj.description
      @resource = 'qrcode'
      return null

  getObject:->
      @qrcode = {
          scene_id:@scene_id,
          ticket:@ticket,
          img_path :@img_path,
          description:@description,
          resource :"qrcode"
      }
      #`#console.log(""+ @id)
      @qrcode["expire_seconds"] = @expire_seconds if @expire
      @qrcode['_id']=@id if @id
      @qrcode['_rev']=@rev if@rev
      return @qrcode

module.exports = QRCode