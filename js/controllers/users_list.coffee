App.initHelpers(['datepicker', 'datetimepicker', 'colorpicker', 'maxlength', 'select2', 'masked-inputs', 'rangeslider', 'tags-inputs']);
aImages = []
Parse.Cloud.run('web_getLangObj').then (res) ->
  console.log 'web_getLangObj success',res
  $language = $('.lang_option')
  $language.empty()
  $.each res.data , (key,value) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="language' + key + '" name="oData[language][]" value="' + key + '"><span></span> ' + value + ' </label>'
    $language.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('manage_getCity',{oOption:{nLimit:100}}).then (res) ->
  console.log 'manage_getCity success',res
  $('#liveIn').empty()
  _ res.data.list.forEach (item) ->
    item = item.toJSON()
    html = "<option value='#{item.objectId}'>#{item.name}</option>"
    $('#liveIn').append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
$('.start_qiniu').click ->
  $('.qiniu_area').show()
  commonFn.qiniuFn()
Parse.Cloud.run('manage_getUserList',{oOption:{nLimit:100}}).then (res) ->
  console.log 'manage_getUserList success',res
  usersList = []
  _ res.data.list.forEach (item) ->
    item = item.toJSON()
    item['linkUserName'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.objectId + ' " target="_blank">' + item.username + '</a>'
    item.createdAt = moment(item.createdAt).format('LLL')
    item.updatedAt = moment(item.updatedAt).format('LLL')
    item['action'] = '<a href="#userModal" data-toggle="modal" data-obj-id="' + item.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
    if item.identity
      item.idType = item.identity.type
      item.idNum = item.identity.number
    usersList.push item
  table = $('#tableUsersList').DataTable
    data: usersList
    bDestroy:true
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
        data:'linkUserName'
        title:'用户名'
      }
      {
        data:'nickname'
        title:'全名'
      }
      {
        data:'email'
        title:'邮箱'
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
    targetId = e.currentTarget.dataset.objId
    targetTr = $(e.currentTarget).parent().parent()
    targetObj = _.find(usersList,{'objectId':targetId})
    $('#editId').val(targetId)
    console.log '匹配到需要编辑的对象',targetObj
    $('.qiniu_area').hide()
    $('.user_info_form')[0].reset()
    $('#success').hide()
    $('.table.table-striped.table-hover.text-left').hide()
    $('#fsUploadProgress').empty()
    $('#summernoteDesc').summernote('destroy')
    $('#summernoteDesc').empty()
    commonFn.fillToForm('user_info_form',targetObj)
    $('#liveIn').val(targetObj.liveIn)
    $('#gender').val(targetObj.gender)
    $('#status').val(targetObj.status)
    $('#address').text(targetObj.address)
    $('#summernoteDesc').append(targetObj.description)
    $('#summernoteDesc').summernote({
      height: 150
    })
    $('input[type="checkbox"]').prop( "checked", false )
    if targetObj.language
      $.each targetObj.language, (key,value) ->
        $('#language' + value + '').prop( "checked", true )
  $('.btn_edit').on('click',editFn)
  $('.btn_edit1').click ->
    targetId = $(@).data('objId')
    targetTr = $(@).parent().parent()
    targetObj = _.find(usersList,{'objectId':targetId})
    $('#editId').val(targetId)
    console.log '匹配到需要编辑的对象',targetObj
    $('.qiniu_area').hide()
    $('.user_info_form')[0].reset()
    $('#success').hide()
    $('.table.table-striped.table-hover.text-left').hide()
    $('#fsUploadProgress').empty()
    $('#summernoteDesc').summernote('destroy')
    $('#summernoteDesc').empty()
    commonFn.fillToForm('user_info_form',targetObj)
    $('#liveIn').val(targetObj.liveIn)
    $('#gender').val(targetObj.gender)
    $('#status').val(targetObj.status)
    $('#address').text(targetObj.address)
    $('#summernoteDesc').append(targetObj.description)
    $('#summernoteDesc').summernote({
      height: 150
    })
    $('input[type="checkbox"]').prop( "checked", false )
    if targetObj.language
      $.each targetObj.language, (key,value) ->
        $('#language' + value + '').prop( "checked", true )
  $('.btn_save').click ->
    saveObj = $('.user_info_form').serializeObject()
    saveObj.oData.Status = parseInt(saveObj.oData.status)
    saveObj.oData.gender = parseInt(saveObj.oData.gender)
    if aImages.length
      saveObj['oData']['avatar'] = aImages[0]
    console.log saveObj
    if $('.user_info_form').valid()
      Parse.Cloud.run('manage_User',saveObj).then (res) ->
        console.log 'manage_User success',res
        newData = res.data.toJSON()
        newData['linkUserName'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.objectId + ' " target="_blank">' + newData.username + '</a>'
        newData.createdAt = moment(newData.createdAt).format('LLL')
        newData.updatedAt = moment(newData.updatedAt).format('LLL')
        newData['action'] = '<a href="#userModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
        table.row(targetTr).data(newData).draw()
        $('#userModal').modal('hide')
        aImages = []
      , (error) ->
        swal '出错了...', error.message, 'error'
        console.log 'Error: ' + error.code + ' ' + error.message
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message

$('.user_info_form').validate
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
    'oData[username]':
      email: true
    'oData[nickname]':
      minlength: 2
    'oData[phoneNumber]':
      number: true
      minlength: 8
      maxlength: 11
    'oData[email]':
      email: true
  messages:
    'oData[username]': '必填,确定是一个正确的邮箱地址'
    'oData[nickname]': '必填,并且至少2个字'
    'oData[phoneNumber]': '必填,确定是一个正确的手机号'
    'oData[email]': '必填,确定是一个正确的邮箱地址'
