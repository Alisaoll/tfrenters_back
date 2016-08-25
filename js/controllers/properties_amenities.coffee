$('.property_amenities_form').validate
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
    'oData[name]':
      required: true
    'oData[englishName]':
      required: true
  messages:
    'oData[name]':
      required: '必须输入中文名称'
    'oData[englishName]':
      required: '必须输入英文名称'
Parse.Cloud.run('web_getPropAmenities',{type:0,list:true,oOption:{ nLimit: 100 }}).then (res) ->
  console.log 'web_getPropAmenities success',res
  list = []
  _ res.data.forEach (item) ->
    itemJson = item.toJSON()
    if itemJson.Status is 0
      itemJson.Status = '正常'
    else
      itemJson.Status = '隐藏'
    itemJson.typeName = extraData.amenitiesType[parseInt(itemJson.type) - 1]
    itemJson.createdAt = moment(itemJson.createdAt).format('LLL')
    itemJson.updatedAt = moment(itemJson.updatedAt).format('LLL')
    itemJson['action'] = '<a href="#propertyAmenModal" data-toggle="modal" data-obj-id="' + itemJson.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
    list.push itemJson
  table = $('#tablePropertiesAmenities').DataTable
    data:list
    bInfo:false
    paging: false
    "aaSorting": [
      [ 5, "desc" ]
    ]
    columns:[
      {
        data:'objectId'
        title:'id'
      }
      {
        data:'code'
        title:'自增ID'
      }
      {
        data:'typeName'
        title:'类型'
      }
      {
        data:'name'
        title:'中文名称'
      }
      {
        data:'englishName'
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
    $('.property_amenities_form')[0].reset()
    targetId = $(@).data('objId')
    if targetId
      targetTr = $(@).parent().parent()
      targetObj = _.find(list,{'objectId':targetId})
      $('#editId').val(targetId)
      commonFn.fillToForm('property_amenities_form',targetObj)
      console.log targetObj
      $('#type').val(targetObj.type)
      if targetObj.Status isnt '正常'
        $('#Status').val(1)
      else
        $('#Status').val(0)
    else
      $('.property_amenities_form input:first').focus()
  $('.btn_save').click ->
    saveObj = $('.property_amenities_form').serializeObject()
    if $('#editId').val().length
      saveObj['oData']['id'] = $('#editId').val()
    saveObj['oData']['type'] = parseInt saveObj.oData.type
    console.log '提交到云代码的obj',saveObj
    if $('.property_amenities_form').valid()
      Parse.Cloud.run('web_Amenities',saveObj).then (res) ->
        console.log 'web_Amenities success',res
        newData = res.data.toJSON()
        newData.updatedAt = moment(newData.createdAt).format('LLL')
        newData.createdAt = moment(newData.updatedAt).format('LLL')
        newData.action = '刷新后再编辑'
        if targetTr
          table.row(targetTr).data(newData).draw()
        else
          table.row.add(newData).draw()
        $('#propertyAmenModal').modal('hide')
      , (error) ->
        swal '出错了...', error.message, 'error'
        console.log 'Error: ' + error.code + ' ' + error.message