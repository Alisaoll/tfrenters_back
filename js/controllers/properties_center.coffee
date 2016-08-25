aImages = []
targetTr = ''
$datepickerMulti = $('.datepicker-multi')
$datepickerRange = $('.input-daterange')
$datepickerMulti.datepicker
  multidate: true
  language: "zh-CN"
  clearBtn: true
$datepickerRange .datepicker
  language: "zh-CN"
  startDate: new Date()
  format: "yyyy-mm-dd"
  autoclose: true
Parse.Cloud.run('web_searchProp').then (res) ->
  totalPages = res.data.count
  $('#pagination-prop').empty().removeData("twbs-pagination").off("page").twbsPagination
    totalPages:Math.ceil totalPages / 20
    visiblePages:10
    onPageClick: (event,page) ->
      console.log 'page on click',event,page
      searchProp =
        oOption:
          nSkip:(page - 1) * 20
      Parse.Cloud.run('web_searchProp',searchProp).then (res) ->
        console.log 'web_searchProp success',res
        propList = []
        _ res.data.list.forEach (item) ->
          if item.attributes.Status isnt 2
            item = item.toJSON()
            item['linkHost'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.ownBy.objectId + ' " target="_blank">' + item.ownBy.nickname + '</a>'
            item['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + item.objectId + ' " target="_blank">' + item.name + '</a>'
            item.createdAt = moment(item.createdAt).format('LLL')
            item.updatedAt = moment(item.updatedAt).format('LLL')
            item.propertyType = item.propertyType.objectId
            item.roomType = item.roomType.objectId
            item.pOwnBy = item.ownBy.objectId
            item.st = item.addr.st
            item.addrCity = item.addr.city
            item.state = item.addr.state
            item.country = item.addr.country
            item.zipCode = item.addr.zipCode
            item.cityGroup = item.city.objectId
            item.discountWeekly = item.discount.weekly
            item.discountMonth = item.discount.month
            item.cityName = item.city.name
            if item['available'] is true
              item.available = '<i class="fa fa-unlock text-success"></i>'
            else
              item.available = '<i class="fa fa-lock text-danger"></i>'
            item['action'] = '<a href="#propertyModal" data-toggle="modal" data-obj-id="' + item.objectId + '" class="btn_edit m-r-10"><i class="fa fa-edit text-primary"></i></a><a href="#;" data-obj-id="' + item.objectId + '" class="btn_remove"><i class="fa fa-trash text-danger"></i></a>'
            propList.push item
        console.log 'web_searchProp to plain obj success',propList
        console.log 'web_searchProp to plain obj success length',propList.length
        $tablePropertiesList = $('#tablePropertiesList')
        table = $tablePropertiesList.DataTable
          data: propList
          bDestroy:true
          bInfo:false
          paging: false
          "aaSorting": [
            [ 6, "desc" ]
          ]
          columns:[
            {
              data:'objectId'
              title:'id'
            }
            {
              data:'linkProperty'
              title:'房源名称'
            }
            {
              data:'linkHost'
              title:'房东全名'
            }
            {
              data:'cityName'
              title:'所处城市圈'
            }
            {
              data:'price'
              title:'价格'
            }
            {
              data:'available'
              title:'可用状态'
            }
            {
              data:'updatedAt'
              title:'最后更新时间'
            }
            {
              data:'action'
              title:'操作'
            }
          ]
        $('.btn_edit').unbind().click ->
          targetId = $(@).data('objId')
          aImages = []
          $('#summernoteDesc').summernote('destroy')
          $('#summernoteRule').summernote('destroy')
          $('.summernote').empty()
          $datepickerMulti.datepicker('clearDates')
          $datepickerRange.datepicker('clearDates')
          $('.property_form')[0].reset()
          console.log targetId
          if targetId
            targetTr = $(@).parent().parent()
            targetObj = _.find(propList,{'objectId':targetId})
            $('#editId').val(targetId)
            console.log '匹配到需要编辑的对象',targetObj
            if targetObj.rule.other
              $('#summernoteRule').append(targetObj.rule.other)
            if targetObj.description
              $('#summernoteDesc').append(targetObj.description)
            $('.summernote').summernote({
              height: 150
            })
            $('.qiniu_area').hide()
            $('#success').hide()
            $('.table.table-striped.table-hover.text-left').hide()
            $('#fsUploadProgress').empty()
            $('#CheckInTime').val(targetObj.CheckInTime)
            $('#CheckOutTime').val(targetObj.CheckOutTime)
            commonFn.fillToForm('property_form',targetObj)
            $('#propertyType').val(targetObj.propertyType)
            $('#roomType').val(targetObj.roomType)
            $('#cityGroup').val(targetObj.cityGroup)
            if targetObj.available is '<i class="fa fa-unlock text-success"></i>'
              $('#available').val('0')
            else
              $('#available').val('1')
#            $('.checkbox_area .cont').hide()
            $('input[type="checkbox"]').prop( "checked", false )
            if targetObj.commonAmenities
              $.each targetObj.commonAmenities, (key,value) ->
                $('#commonAmenities' + value + '').prop( "checked", true )
            if targetObj.surrounding
              $.each targetObj.surrounding, (key,value) ->
                $('#surrounding' + value + '').prop( "checked", true )
            if targetObj.valueAddedServiece
              $.each targetObj.valueAddedServiece, (key,value) ->
                $('#valueAddedServiece' + value + '').prop( "checked", true )
            if targetObj.otherAmenities
              $.each targetObj.otherAmenities, (key,value) ->
                $('#otherAmenities' + value + '').prop( "checked", true )
            $('.open_date_multi').click ->
              $('.datepicker_area').toggle()
              $datepickerRange.datepicker('clearDates')
              if targetObj.invalidDates
                $datepickerMulti.datepicker('setDates',targetObj.invalidDates)
            $('.open_date_range').click ->
              $('.datepicker_area').toggle()
              $datepickerMulti.datepicker('clearDates')
            $('.clear_date').click ->
              $datepickerMulti.datepicker('clearDates')
              $datepickerRange.datepicker('clearDates')
#            $datepickerRange.datepicker('setDates',['2016-06-23','2016-06-24','2016-06-25'])
  #          if targetObj.invalidDates
  #            $('.js-datepicker-in').datepicker('setDates',targetObj.invalidDates)
          else
            targetTr = ''
            $('#editId').val('')
            $('.propertyModal input:first').focus()
            $('#pOwnBy').val(extraData.currentUserInfo.objectId)
            $('.summernote').summernote({
              height: 150
            })
        $('.btn_save').unbind().click ->
          if $('.property_form').valid()
            that = this
            $('.btn_save').prop('disabled',true)
            saveObj = $('.property_form').serializeObject()
            aInvalidDates = $('.js-datepicker-in').datepicker('getDates')
            saveObj.oData.description = $('#summernoteDesc').summernote('code')
            saveObj.oData.rule = {}
            saveObj.oData.rule.other = $('#summernoteRule').summernote('code')
            if aInvalidDates.length
              saveObj['oData']['invalidDates'] = aInvalidDates
            if saveObj['oData']['available'] is '0'
              saveObj['oData']['available'] = true
            else
              saveObj['oData']['available'] = false
            if $('#editId').val().length
              saveObj['oData']['id'] = $('#editId').val()
            if aImages.length
              saveObj['oData']['images'] = aImages
            saveObj['oData']['commonAmenities'] = []
            saveObj['oData']['surrounding'] = []
            saveObj['oData']['valueAddedServiece'] = []
            saveObj['oData']['otherAmenities'] = []
            saveObj['oData']['securityAmenities'] = []
            $('input[name="commonAmenities"]:checked').each ->
              saveObj['oData']['commonAmenities'].push(@.value)
            $('input[name="surrounding"]:checked').each ->
              saveObj['oData']['surrounding'].push(@.value)
            $('input[name="valueAddedServiece"]:checked').each ->
              saveObj['oData']['valueAddedServiece'].push(@.value)
            $('input[name="otherAmenities"]:checked').each ->
              saveObj['oData']['otherAmenities'].push(@.value)
            $('input[name="securityAmenities"]:checked').each ->
              saveObj['oData']['securityAmenities'].push(@.value)
            saveObj.oData.maxGuest = parseInt(saveObj.oData.maxGuest)
            saveObj.oData.bathroomCount = parseInt(saveObj.oData.bathroomCount)
            saveObj.oData.bedroomCount = parseInt(saveObj.oData.bedroomCount)
            saveObj.oData.bedCount = parseInt(saveObj.oData.bedCount)
            saveObj.oData.price = parseInt(saveObj.oData.price)
            saveObj.oData.lessDays = parseInt(saveObj.oData.lessDays)
            saveObj.oData.CleanFee = parseInt(saveObj.oData.CleanFee)
            saveObj.oData.ServiceFee = parseInt(saveObj.oData.ServiceFee)
            saveObj.oData.Status = parseInt(saveObj.oData.Status)
            saveObj.oData.CheckInTime = parseInt(saveObj.oData.CheckInTime)
            saveObj.oData.CheckOutTime = parseInt(saveObj.oData.CheckOutTime)
            saveObj.oData.deposit = parseInt(saveObj.oData.deposit)
            saveObj.oData.tax = parseInt(saveObj.oData.tax)
            console.log saveObj
            Parse.Cloud.run('manage_Property',saveObj).then (res) ->
              $('.btn_save').prop('disabled',false)
              console.log 'manage_Property success',res
              newData = res.data.toJSON()
              console.log 'manage_Property success',newData
              aImages = []
              newData.linkProperty = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + newData.objectId + ' " target="_blank">' + newData.name + '</a>'
              newData.linkHost = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.ownBy.objectId + ' " target="_blank">' + newData.ownBy.nickname + '</a>'
              newData.cityName = newData.city.name
              newData.createdAt = moment(newData.createdAt).format('YYYY-MM-DD hh:mm:ss')
              newData.updatedAt = moment(newData.updatedAt).format('YYYY-MM-DD hh:mm:ss')
              if newData['available'] is true
                newData.available = '<i class="fa fa-unlock text-success"></i>'
              else
                newData.available = '<i class="fa fa-lock text-danger"></i>'
              newData.action1 = '<a href="#propertyModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit m-r-10"><i class="fa fa-edit text-primary"></i></a><a href="#;" data-obj-id="' + newData.objectId + '" class="btn_remove"><i class="fa fa-trash text-danger"></i></a>'
              newData.action = '刷新页面后编辑'
              if targetTr
                if newData.Status is 2
                  table.row(targetTr).remove().draw()
                else
                  table.row(targetTr).data(newData).draw()
              else
                table.row.add(newData).draw()
              if $(that).hasClass('go_on')
                $('#pOwnBy').val(extraData.currentUserInfo.objectId)
                $('.property_form')[0].reset()
                $('.summernote').empty()
                $('.propertyModal input:first').focus()
                $('#pOwnBy').val(extraData.currentUserInfo.objectId)
              else
                $('#propertyModal').modal('hide')
            , (error) ->
              swal '出错了...', error.message, 'error'
              console.log 'Error: ' + error.code + ' ' + error.message
        $('.btn_remove').unbind().click ->
          $this = $(@)
          swal({
            title: "你确定需要在前台后台都隐藏该房源吗?",
            text: "数据隐藏后,你依然可以通过筛选和编辑更改这个房源的状态!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "是的,隐藏它!",
            cancelButtonText: "取消",
            closeOnConfirm: false
          }, (isConfirm) ->
            if isConfirm
              $('.btn_save').prop('disabled',true)
              objId = $this.data('objId')
              targetTr = $this.parent().parent()
              saveObj = {
                oData:{
                  id:objId
                  Status:2
                }
              }
              Parse.Cloud.run('manage_Property',saveObj).then (res) ->
                console.log res.data.toJSON()
                $('.btn_save').prop('disabled',false)
                table.row(targetTr).remove().draw()
                swal({
                  title: "隐藏成功!",
                  text: "数据隐藏后,你依然可以通过筛选和编辑更改这个房源的状态!",
                  type: "success",
                  timer: 2000,
                  showConfirmButton: false
                })
              , (error) ->
                swal '出错了...', error.message, 'error'
                console.log 'Error: ' + error.code + ' ' + error.message
          )
      , (error) ->
        swal '出错了...', error.message, 'error'
#$('.checkbox_area .cont').hide()
$('.checkbox_area .tit').click ->
  $('.cont',@.parentNode).slideToggle()
  $('.text',@).toggle()
$('.start_qiniu').click ->
  $('.qiniu_area').show()
  commonFn.qiniuFn()
Parse.Cloud.run('manage_getCity').then (res) ->
  console.log 'manage_getCity success',res
  $('#cityGroup').empty()
  _ res.data.list.forEach (item) ->
    item = item.toJSON()
    html = "<option value='#{item.objectId}'>#{item.name}</option>"
    $('#cityGroup').append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('manage_getPropertyRoomType').then (res) ->
  console.log 'manage_getPropertyRoomType success',res
  $('#roomType').empty()
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      item = item.toJSON()
      html = "<option value='#{item.objectId}'>#{item.RoomType}</option>"
      $('#roomType').append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('manage_getPropertyType').then (res) ->
  console.log 'manage_getPropertyType success',res
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      item = item.toJSON()
      html = "<option value='#{item.objectId}'>#{item.chineseName}</option>"
      $('#propertyType').append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('web_getPropAmenities',{type:1,list:false}).then (res) ->
  console.log 'web_getPropAmenities success',res
  $amenities_list = $('.amenities_list')
  $amenities_list.empty()
  list = []
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      list.push item.toJSON()
  $.each list , (key,val) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="commonAmenities' + val.code + '" name="commonAmenities" value="' + val.code + '"><span></span> ' + val.name + ' </label>'
    $amenities_list.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('web_getPropAmenities',{type:2,list:false}).then (res) ->
  console.log 'web_getPropAmenities success',res
  $amenities_list = $('.surround_list')
  $amenities_list.empty()
  list = []
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      list.push item.toJSON()
  $.each list , (key,val) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="surrounding' + val.code + '" name="surrounding" value="' + val.code + '"><span></span> ' + val.name + ' </label>'
    html1 = ' <label class="checkbox-inline" for="surrounding' + val.code + '"> <input type="checkbox" id="surrounding' + val.code + '" name="surrounding" value="' + val.code + '">' + val.name + '</label> '
    $amenities_list.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('web_getPropAmenities',{type:3,list:false}).then (res) ->
  console.log 'web_getPropAmenities success',res
  $amenities_list = $('.value_list')
  $amenities_list.empty()
  list = []
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      list.push item.toJSON()
  $.each list , (key,val) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="valueAddedServiece' + val.code + '" name="valueAddedServiece" value="' + val.code + '"><span></span> ' + val.name + ' </label>'
    $amenities_list.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('web_getPropAmenities',{type:4,list:false}).then (res) ->
  console.log 'web_getPropAmenities success',res
  $amenities_list = $('.other_amenities_list')
  $amenities_list.empty()
  list = []
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      list.push item.toJSON()
  $.each list , (key,val) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="otherAmenities' + val.code + '" name="otherAmenities" value="' + val.code + '"><span></span> ' + val.name + ' </label>'
    html1 = ' <label class="checkbox-inline" for="otherAmenities' + val.code + '"> <input type="checkbox" id="otherAmenities' + val.code + '" name="otherAmenities" value="' + val.code + '">' + val.name + '</label> '
    $amenities_list.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
Parse.Cloud.run('web_getPropAmenities',{type:5,list:false}).then (res) ->
  console.log 'web_getPropAmenities success',res
  $amenities_list = $('.security_list')
  $amenities_list.empty()
  list = []
  _ res.data.list.forEach (item) ->
    if item.attributes.Status is 0
      list.push item.toJSON()
  $.each list , (key,val) ->
    html = '<label class="css-input css-checkbox css-checkbox-primary m-r-15"> <input type="checkbox" id="securityAmenities' + val.code + '" name="securityAmenities" value="' + val.code + '"><span></span> ' + val.name + ' </label>'
    html1 = ' <label class="checkbox-inline" for="securityAmenities' + val.code + '"> <input type="checkbox" id="securityAmenities' + val.code + '" name="securityAmenities" value="' + val.code + '">' + val.name + '</label> '
    $amenities_list.append(html)
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message
App.initHelpers(['datepicker', 'datetimepicker', 'colorpicker', 'maxlength', 'select2', 'masked-inputs', 'rangeslider', 'tags-inputs']);
$('.property_form').validate
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
    'oData[ownBy]':
      required: true
      minlength: 10
      maxlength: 10
    'oData[price]':
      required: true
      number: true
    'oData[CleanFee]':
      number: true
    'oData[ServiceFee]':
      number: true
    'oData[lessDays]':
      number: true
    'oData[bedroomCount]':
      number: true
    'oData[maxGuest]':
      number: true
    'oData[bedCount]':
      number: true
    'oData[bathroomCount]':
      number: true
    'oData[addr][zipCode]':
      number: true
  messages:
    'oData[name]':
      required: '请输入房源名称'
      minlength: '房源名称应该至少有两个字'
    'oData[ownBy]':
      required: '必须指定一个房东的objectId'
    'oData[price]':
      required:'必须输入,且为数字'
    'oData[bedroomCount]': '必须输入,且为数字'
    'oData[maxGuest]': '必须输入,且为数字'
    'oData[bedCount]': '必须输入,且为数字'
    'oData[bathroomCount]': '必须输入,且为数字'
#禁用日期

addDay = (date, number) ->
  a = new Date(date)
  a = a.valueOf()
  a = a + number * 24 * 60 * 60 * 1000
  a = new Date(a)
  a

GMT_TO_UTC = (dd) ->
  a = new Date(dd)
  a = a.valueOf()
  a = a + 8 * 60 * 60 * 1000
  a = new Date(a)
  a

#处理时间 格式为yy-mm-dd

timetall = (time1) ->
  if time1
    date = time1.getDate()
    month = time1.getMonth()
    month = month + 1
    if month <= 9
      month = '0' + month
    year = time1.getFullYear()
    time = year + '-' + month + '-' + date
    return time
  return

#显示一段时间

show = (value1, value2, arr) ->
  if value2 == null
    value2 = value1

  getDate = (str) ->
    tempDate = new Date
    list = str.split('-')
    tempDate.setFullYear list[0]
    tempDate.setMonth list[1] - 1
    tempDate.setDate list[2]
    tempDate

  date1 = getDate(value1)
  date2 = getDate(value2)
  if date1 > date2
    tempDate = date1
    date1 = date2
    date2 = tempDate
  #   date1.setDate(date1.getDate());
  while !(date1.getFullYear() == date2.getFullYear() and date1.getMonth() == date2.getMonth() and date1.getDate() == date2.getDate())
    res = date1.getFullYear() + '-' + date1.getMonth() + 1 + '-' + date1.getDate()
    arr.push res
    date1.setDate date1.getDate() + 1
  return

$('#calendar_save').click ->
  time_start = []
  time_end = []
  events = []
  res = $('#calendar').fullCalendar('clientEvents')
  i = 0
  while i < res.length
    time_start.push res[i]._start._d
    events.push
      start: timetall(res[i]._start._d)
      end: timetall(res[i]._end._d)
    i++
  console.log res
  resarr = []
  i = 0
  while i < events.length
    show events[i].start, events[i].end, resarr
    i++
  console.log resarr
  return
$('#all').click ->
  swal '出错了...', '是否全部清除', 'error'
  $('#calendar').fullCalendar 'removeEvents'
  return
$('#add').click ->
  start1 = $('#full_start').val()
  end1 = $('#full_end').val()
  title1 = $('#full_title').val()
  startdate_ = GMT_TO_UTC(new Date(start1))
  enddate_ = GMT_TO_UTC(new Date(end1))
  today_date = new Date
  if startdate_ < today_date
    swal '出错了...', '起始日期不能小于当天日期！', 'error'
    return
  if startdate_ > enddate_
    swal '出错了...', '起始日期不能大于结束日期！', 'error'
    return
  events = []
  res = $('#calendar').fullCalendar('clientEvents')
  if start1
    i = 0
    while i < res.length
      events.push
        start: timetall(res[i]._start._d)
        end: timetall(if res[i]._end then res[i]._end._d else res[i]._start._d)
      i++
  i = 0
  while i < events.length
    temp_start = GMT_TO_UTC(new Date(events[i].start.replace(/-/g, '/')))
    temp_end_ = if events[i].end then events[i].end else events[i].start
    temp_end = GMT_TO_UTC(new Date(temp_end_.replace(/-/g, '/')))
    if startdate_ >= temp_start and startdate_ <= temp_end
      startdate_ = temp_start
    if enddate_ >= temp_start and enddate_ <= temp_end
      enddate_ = temp_end
    i++
  $('#calendar').fullCalendar 'removeEvents', (event) ->
    temp_date_end = if event.end then event.end._d else event.start._d
    if startdate_ <= event.start._d and enddate_ >= temp_date_end
      return true
    false
  $('#calendar').fullCalendar 'renderEvent',
    title: title1
    start: startdate_
    end: enddate_
    allDay: true
    id: date
  return
$('#if_calendar').click ->
  $('.show-calendar').toggle()
  setTimeout $('#calendar').fullCalendar(
    header:
      right: 'prev,next'
      center: 'title'
      left: 'month'
    defaultView: 'month'
    editable: true
    droppable: true
    monthNames: [
      '一月'
      '二月'
      '三月'
      '四月'
      '五月'
      '六月'
      '七月'
      '八月'
      '九月'
      '十月'
      '十一月'
      '十二月'
    ]
    monthNamesShort: [
      '一月'
      '二月'
      '三月'
      '四月'
      '五月'
      '六月'
      '七月'
      '八月'
      '九月'
      '十月'
      '十一月'
      '十二月'
    ]
    dayNames: [
      '周日'
      '周一'
      '周二'
      '周三'
      '周四'
      '周五'
      '周六'
    ]
    dayNamesShort: [
      '周日'
      '周一'
      '周二'
      '周三'
      '周四'
      '周五'
      '周六'
    ]
    today: [ '今天' ]
    firstDay: 1
    buttonText:
      today: '今天'
      month: '月'
      week: '周'
      day: '日'
      prev: '上一月'
      next: '下一月'
    events: [
      {
        title: '日期不可用'
        start: '/07/27/2016/'
        end: '/07/30/2016/'
        allDay: true
        color: '#3797df'
      }
      {
        title: '日期不可用'
        start: '2016-06-23'
        end: '2016-06-25'
        color: '#3797df'
      }
      {
        title: '日期不可用'
        start: '06/30/2016/'
        end: '07/09/2016/'
        allDay: true
        color: '#3797df'
      }
    ]
    dayClick: (date, event, jsEvent, resourceObj) ->
      today_date = new Date
      day_enddate = addDay(date, 1)
      if date > today_date
        events = $('#calendar').fullCalendar('clientEvents', (event) ->
          eventStart = event.start._d
          eventEnd = if event.end then addDay(event.end._d, -1) else eventStart
          theDate = date._d
          eventStart <= theDate and eventEnd >= theDate and !(eventStart < theDate and eventEnd == theDate) or eventStart == theDate and eventEnd == null
        )
        console.log 'evnet', events
        if events.length == 0
          $('#calendar').fullCalendar 'renderEvent',
            title: '日期不可用'
            start: date
            end: day_enddate
            allDay: true
            color: '#3797df'
        else
          if events[0].start._d < today_date
            swal '出错了...', '今天之前的进程不能删除', 'error'
          else
            $('#calendar').fullCalendar 'removeEvents', events[0]._id
#删除事件
      else
        swal '出错了...', '今天之前的时间无法添加日程', 'error'
      return
  ), 500
  return
$('#full_start').datepicker().on 'hide', ->
  dateRange1_1 = undefined
  lessSelect = undefined
  dateRange1_1 = $('#full_start').datepicker('getDate')
  if dateRange1_1
    lessSelect = moment(dateRange1_1).add(1, 'days').format('YYYY-MM-DD')
    $('#full_end').datepicker 'setDate', lessSelect
    return $('#full_end').datepicker('show')
  return