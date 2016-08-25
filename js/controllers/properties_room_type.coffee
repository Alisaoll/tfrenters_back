$('.property_room_type_form').validate
  ignore: []
  errorClass: 'help-block text-right animated fadeInDown'
  errorElement: 'div'
  errorPlacement: (error, e) ->
    jQuery(e).parents('.form-group > div').append error
    return
  highlight: (e) ->
    elem = jQuery(e)
    elem.closest('.form-group').removeClass('has-error').addClass 'has-error'
    elem.closest('.help-block').remove()
    return
  success: (e) ->
    elem = jQuery(e)
    elem.closest('.form-group').removeClass 'has-error'
    elem.closest('.help-block').remove()
    return
  rules:
    'oData[RoomType]':
      required: true
      minlength: 2
    'oData[RoomTypeEnglish]':
      required: true
      minlength: 2
  messages:
    'oData[RoomType]':
      required: '必须输入中文名称'
      minlength: '至少有2个字'
    'oData[RoomTypeEnglish]':
      required: '必须输入英文名称'
      minlength: '至少有2个字'
Parse.Cloud.run('manage_getPropertyRoomType',{oOption:{ nLimit: 100 }}).then (res) ->
  console.log 'manage_getPropertyRoomType success',res
  typesList = []
  _ res.data.list.forEach (item) ->
    itemJson = item.toJSON()
    if itemJson.Status is 0
      itemJson.Status = '正常'
    else
      itemJson.Status = '隐藏'
    itemJson.createdAt = moment(itemJson.createdAt).format('LLL')
    itemJson.updatedAt = moment(itemJson.updatedAt).format('LLL')
    itemJson['action'] = '<a href="#propertyRoomTypeModal" data-toggle="modal" data-obj-id="' + itemJson.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
    typesList.push itemJson
  table = $('#tablePropertiesRoomTypes').DataTable
    data:typesList
    bInfo:false
    paging: false
    "aaSorting": [
      [ 3, "desc" ]
    ]
    columns:[
      {
        data:'objectId'
        title:'id'
      }
      {
        data:'RoomType'
        title:'中文名称'
      }
      {
        data:'RoomTypeEnglish'
        title:'英文名称'
      }
      {
        data:'Status'
        title:'状态'
      }
      {
        data:'updatedAt'
        title:'更新时间'
      }
      {
        data:'createdAt'
        title:'创建时间'
      }
      {
        data:'action'
        title:'操作'
      }
    ]
  targetTr = ''
  $('.btn_edit').click ->
    $('.property_room_type_form')[0].reset()
    targetId = $(@).data('objId')
    if targetId
      targetTr = $(@).parent().parent()
      targetObj = _.find(typesList,{'objectId':targetId})
      $('#editId').val(targetId)
      commonFn.fillToForm('property_room_type_form',targetObj)
      if targetObj.Status isnt '正常'
        $('#Status').val(1)
      else
        $('#Status').val(0)
    else
      $('.property_room_type_form input:first').focus()
  $('.btn_save').click ->
    saveObj = $('.property_room_type_form').serializeObject()
    if $('#editId').val().length
      saveObj['oData']['id'] = $('#editId').val()
    console.log '提交到云代码的obj',saveObj
    if $('.property_room_type_form').valid()
      Parse.Cloud.run('manage_PropertyRoomType',saveObj).then (res) ->
        console.log 'manage_PropertyRoomType success',res
        newData = res.data.toJSON()
        newData.updatedAt = moment(newData.createdAt).format('LLL')
        newData.createdAt = moment(newData.updatedAt).format('LLL')
        newData.action = '<a href="#propertyRoomTypeModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
        if targetTr
          table.row(targetTr).data(newData).draw()
        else
          table.row.add(newData).draw()
        $('#propertyRoomTypeModal').modal('hide')
      , (error) ->
        swal '出错了...', error.message, 'error'
        console.log 'Error: ' + error.code + ' ' + error.message
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message