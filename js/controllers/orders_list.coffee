App.initHelpers(['datepicker', 'datetimepicker', 'colorpicker', 'maxlength', 'select2', 'masked-inputs', 'rangeslider', 'tags-inputs']);
Parse.Cloud.run('manage_getOrderList').then (res) ->
  console.log 'manage_getOrderList success',res
  ordersList = commonFn.transferData(res.data)
  _ ordersList.forEach (item) ->
    item.createdAt = moment(item.createdAt).format('YYYY-MM-DD')
    item.updatedAt = moment(item.updatedAt).format('YYYY-MM-DD')
    item['linkHost'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.host.objectId + ' " target="_blank">' + item.host.nickname + '</a>'
    item['linkUser'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.user.objectId + ' " target="_blank">' + item.user.nickname + '</a>'
    item['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + item.property.objectId + ' " target="_blank">' + item.property.name + '</a>'
    item['action'] = '<a href="#oderModal" data-toggle="modal" data-obj-id="' + item.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
  console.log ordersList
  table = $('#tableOrdersList').DataTable
    data: ordersList
    columns:[
      {
        data:'objectId'
        title:'id'
      }
      {
        data:'linkProperty'
        title:'预订的房源'
      }
      {
        data:'linkHost'
        title:'房东'
      }
      {
        data:'linkUser'
        title:'消费者'
      }
      {
        data:'totalAmount'
        title:'总金额'
      }
      {
        data:'status'
        title:'订单状态'
      }
      {
        data:'checkIn'
        title:'入住时间'
      }
      {
        data:'checkOut'
        title:'离开时间'
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
    $('.order_form')[0].reset()
    targetId = $(@).data('objId')
    if targetId
      targetTr = $(@).parent().parent()
      targetObj = _.find(ordersList,{'objectId':targetId})
      $('#editId').val(targetId)
      console.log '匹配到需要编辑的对象',targetObj
      commonFn.fillToForm('order_form',targetObj)
      propertyId = targetObj.property.objectId
      $('#propertyId').val(propertyId)
  $('.btn_save').click ->
    saveObj = $('.order_form').serializeObject()
    saveObj.oData.status = parseInt(saveObj.oData.status)
    saveObj.oData.price = parseInt(saveObj.oData.price)
    if $('#editId').val().length
      saveObj['oData']['id'] = $('#editId').val()
    console.log saveObj
    Parse.Cloud.run('manage_Order',saveObj).then (res) ->
      console.log 'manage_Order success',res
      newData = res.data.toJSON()
      newData.createdAt = moment(newData.createdAt).format('YYYY-MM-DD')
      newData.updatedAt = moment(newData.updatedAt).format('YYYY-MM-DD')
      newData['linkHost'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.host.objectId + ' " target="_blank">' + newData.host.nickname + '</a>'
      newData['linkUser'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.user.objectId + ' " target="_blank">' + newData.user.nickname + '</a>'
      newData['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + newData.property.objectId + ' " target="_blank">' + newData.property.name + '</a>'
      newData['action'] = '<a href="#oderModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>'
      if targetTr
        table.row(targetTr).data(newData).draw()
      else
        table.row.add(newData).draw()
      $('#oderModal').modal('hide')
    , (error) ->
      swal '出错了...', error.message, 'error'
      console.log 'Error: ' + error.code + ' ' + error.message
, (error) ->
  swal '出错了...', error.message, 'error'
  console.log 'Error: ' + error.code + ' ' + error.message