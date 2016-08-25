#Parse.Cloud.run('web_getPropAmenities').then (res) ->
#  console.log 'web_getPropAmenities success',res
#, (error) ->
#  swal '出错了...', error.message, 'error'
#  console.log 'Error: ' + error.code + ' ' + error.message
#Parse.Cloud.run('web_searchProp').then (res) ->
#  console.log 'web_searchProp success',res
#, (error) ->
#  swal '出错了...', error.message, 'error'
#  console.log 'Error: ' + error.code + ' ' + error.message
#Parse.Cloud.run('manage_getUserList').then (res) ->
#  console.log 'manage_getUserList success',res
#, (error) ->
#  swal '出错了...', error.message, 'error'
#  console.log 'Error: ' + error.code + ' ' + error.message
#Parse.Cloud.run('manage_getOrderList').then (res) ->
#  console.log 'manage_getOrderList success',res
#, (error) ->
#  swal '出错了...', error.message, 'error'
#  console.log 'Error: ' + error.code + ' ' + error.message
$('.property_type_form').validate
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
    'oData[chineseName]':
      required: true
      minlength: 2
      maxlength: 8
    'oData[englishName]':
      required: true
      minlength: 4
      maxlength: 20
  messages:
    'oData[chineseName]':
      required: '必须输入中文名称'
      minlength: '至少有2个字'
      maxlength: '至多有8个字'
    'oData[englishName]':
      required: '必须输入英文名称'
      minlength: '至少有4个字'
      maxlength: '至多有20个字'
Parse.Cloud.run('manage_getPropertyType',{oOption:{ nLimit: 100 }}).then (res) ->
  console.log 'manage_getPropertyType success',res
  typesList = []
  _ res.data.list.forEach (item) ->
    itemJson = item.toJSON()
    if itemJson.Status is 0
      itemJson.Status = '正常'
    else
      itemJson.Status = '隐藏'
    itemJson.createdAt = moment(itemJson.createdAt).format('LLL')
    itemJson.updatedAt = moment(itemJson.updatedAt).format('LLL')
    itemJson['action'] = '<a href="#propertyTypeModal" data-toggle="modal" data-obj-id="' + itemJson.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
    typesList.push itemJson
  table = $('#tablePropertiesTypes').DataTable
    data:typesList
    "aaSorting": [
      [ 3, "desc" ]
    ]
    columns:[
      {
        data:'objectId'
        title:'id'
      }
      {
        data:'chineseName'
        title:'中文标题'
      }
      {
        data:'englishName'
        title:'英文标题'
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
  editFn = (e) ->
    console.log e
    $('.property_type_form')[0].reset()
    targetId = e.currentTarget.dataset.objId
    if targetId
      targetTr = $(e.currentTarget).parent().parent()
      targetObj = _.find(typesList,{'objectId':targetId})
      $('#editId').val(targetId)
      $('#chineseName').val(targetObj.chineseName)
      $('#englishName').val(targetObj.englishName)
      if targetObj.Status isnt '正常'
        $('#Status').val(1)
      else
        $('#Status').val(0)
    else
      $('.property_type_form input:first').focus()
  $('.btn_edit').on('click',editFn)
  $('.btn_save').click ->
    saveObj = $('.property_type_form').serializeObject()
    if $('#editId').val().length
      saveObj['oData']['id'] = $('#editId').val()
    console.log '提交到云代码的obj',saveObj
    if $('.property_type_form').valid()
      Parse.Cloud.run('manage_PropertyType',saveObj).then (res) ->
        console.log 'manage_PropertyType success',res
        newData = res.data.toJSON()
        newData.updatedAt = moment(newData.updatedAt).format('LLL')
        newData.createdAt = moment(newData.createdAt).format('LLL')
        newData.action = '<a href="#propertyTypeModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
        if targetTr
          table.row(targetTr).data(newData).draw()
        else
          table.row.add(newData).draw()
        $('#propertyTypeModal').modal('hide')
      , (error) ->
        swal '出错了...', error.message, 'error'
        console.log 'Error: ' + error.code + ' ' + error.message
  $('.btn_delete').click ->
    target = $(@).data('objId')
    console.log target
    swal
      title: "确定删除这个类型吗",
      text: "如果依然有房源属于这个类型,那将会出现程序崩溃的惨状",
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: "干它!",
      cancelButtonText: "我怂了...",
      closeOnConfirm: false
    , ->
      swal("恭喜你!", "删除了一个房源类型,是福是祸不好说.不过告诉你一个好消息,现在暂无删除功能!", "success");
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message