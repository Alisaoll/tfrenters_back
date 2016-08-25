$('.city_group_form').validate
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
      minlength: 2
      maxlength: 8
    'oData[englishName]':
      required: true
  messages:
    'oData[name]':
      required: '必须输入中文名称'
      minlength: '至少有2个字'
      maxlength: '至多有8个字'
    'oData[englishName]':
      required: '必须输入英文名称'
Parse.Cloud.run('manage_getCity',{oOption:{ nLimit: 100 }}).then (res) ->
  console.log 'manage_getCity success',res
  citiesList = []
  _ res.data.list.forEach (item) ->
    itemJson = item.toJSON()
    if itemJson.Status is 0
      itemJson.Status = '正常'
    else
      itemJson.Status = '隐藏'
    itemJson.createdAt = moment(itemJson.createdAt).format('LLL')
    itemJson.updatedAt = moment(itemJson.updatedAt).format('LLL')
    itemJson['action'] = '<a href="#cityGroupModal" data-toggle="modal" data-obj-id="' + itemJson.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
    citiesList.push itemJson
  table = $('#tableCityGroup').DataTable
    data:citiesList
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
    $('.city_group_form')[0].reset()
    targetId = $(@).data('objId')
    console.log targetId
    if targetId
      targetTr = $(@).parent().parent()
      targetObj = _.find(citiesList,{'objectId':targetId})
      $('#editId').val(targetId)
      commonFn.fillToForm('city_group_form',targetObj)
      if targetObj.Status isnt '正常'
        $('#Status').val(1)
      else
        $('#Status').val(0)
    else
      $('.city_group_form input:first').focus()
  $('.btn_save').click ->
    saveObj = $('.city_group_form').serializeObject()
    if $('#editId').val().length
      saveObj['oData']['id'] = $('#editId').val()
    console.log '提交到云代码的obj',saveObj
    if $('.city_group_form').valid()
      Parse.Cloud.run('manage_City',saveObj).then (res) ->
        console.log 'manage_City success',res
        newData = res.data.toJSON()
        newData.updatedAt = moment(newData.updatedAt).format('LLL')
        newData.createdAt = moment(newData.createdAt).format('LLL')
        newData.action = '刷新后再编辑'
        if targetTr
          table.row(targetTr).data(newData).draw()
        else
          table.row.add(newData).draw()
        $('#cityGroupModal').modal('hide')
      , (error) ->
        swal '出错了...', error.message, 'error'
        console.log 'Error: ' + error.code + ' ' + error.message
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message