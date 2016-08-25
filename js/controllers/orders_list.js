// Generated by CoffeeScript 1.10.0
App.initHelpers(['datepicker', 'datetimepicker', 'colorpicker', 'maxlength', 'select2', 'masked-inputs', 'rangeslider', 'tags-inputs']);


$datepickerRange = $('.input-daterange');
var searchProp;

// 启动日期选择插件
$('#order-checkIn').datepicker({
    language: "zh-CN",
    startDate: new Date(),
    format: "yyyy-mm-dd",
    autoclose: true
});

$('#order-checkOut').datepicker({
    language: "zh-CN",
    startDate: new Date(new Date().getTime() + 86400000),
    format: "yyyy-mm-dd",
    autoclose: true
});

var _count;

var search=function (oData1,oData2) {
    console.log(oData1);
    Parse.Cloud.run('manage_getOrderList',oData1).then(function(res) {
        var editFn, table, targetTr, usersList;
        var totalPages = res.data.count;
        if(totalPages<1){
            $('#pagination-prop').empty();
           $('#tableOrdersList').html('暂无匹配的对象');
        }else{
            $('#tableOrdersList').empty();
            return $('#pagination-prop').empty().removeData("twbs-pagination").off("page").twbsPagination({
                totalPages:  Math.ceil(totalPages / 20),
                visiblePages: 10,
                onPageClick: function (event, page) {
                    var searchProp;
                    console.log('page on click', event, page);
                    searchProp = {
                        oData:oData2,
                        oOption: {
                            nSkip: (page - 1) * 20
                        },
                        link:{}
                    };
                    console.log(searchProp);
                    return Parse.Cloud.run('manage_getOrderList', searchProp).then(function (res) {
                        var ordersList, table, targetTr;
                        console.log('manage_getOrderList success', res);
                        ordersList = commonFn.transferData(res.data.list);
                        console.log("ddd", res);
                        function status(items_status) {
                            switch (items_status) {
                                case 0:
                                    return '等待付款';
                                    break;
                                case 100:
                                    return '用户主动取消订单';
                                    break;
                                case 200:
                                    return '等待房东确认';
                                    break;
                                case 201:
                                    return '房东取消未确认的订单';
                                    break;
                                case 202:
                                    return '已取消订单';
                                    break;
                                case 500:
                                    return '未确认的订单，自动取消';
                                    break;
                                case 501:
                                    return '未确认订单，自动取消去授权失败';
                                    break;
                                case 502:
                                    return '已取消订单';
                                    break;
                                case 1000:
                                    return '房东已确认的订单';
                                    break;
                                case 1001:
                                    return '已确认订单，自动capture失败';
                                    break;
                                case 1002:
                                    return '房东已确认的订单';
                                    break;
                                case 1100:
                                    return '已申请取消订单，等待确认';
                                    break;
                                case 1101:
                                    return '已取消的订单';
                                    break;
                                case 1102:
                                    return '已取消的订单';
                                    break;
                                case 1103:
                                    return '已取消的订单';
                                    break;
                                case 2000:
                                    return '入住中';
                                    break;
                                case 2001:
                                    return '已申请提请退房';
                                    break;
                                case 3000:
                                    return '退房中';
                                    break;
                                case 4000:
                                    return '已完成订单';
                                    break;
                                case 4001:
                                    return '已完成订单，自动退还押金失败';
                                    break;
                                case 4002:
                                    return '已完成订单';
                                    break;
                                case 9800:
                                    return '未支付订单，自动取消';
                                    break;
                            }
                        }

                        console.log('ordersList', ordersList);
                        if(ordersList!=false) {
                            _(ordersList.forEach(function (item) {
                                item.createdAt = moment(item.createdAt).format('LLL');
                                item.updatedAt = moment(item.updatedAt).format('LLL');
                                item.checkIn = moment(item.checkIn).format('YYYY-MM-DD');
                                item.checkOut = moment(item.checkOut).format('YYYY-MM-DD');
                                if (item.property) {
                                    item.property.address = JSON.parse(item.property.address)
                                }
                                ;
                                item['statustx'] = status(item.status);
                                item['linkHost'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.host.objectId + ' " target="_blank">' + item.host.nickname + '</a>';
                                item['linkUser'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + item.user.objectId + ' " target="_blank">' + item.user.nickname + '</a>';
                                if (item.property) {
                                    item['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + item.property.objectId + ' " target="_blank">' + item.property.name + '</a>';
                                } else {
                                    item['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html" target="_blank">暂无</a>';
                                }
                                return item['action'] = '<a href="#oderModal" data-toggle="modal" data-obj-id="' + item.objectId + '" class="btn_edit m-r-10"><i class="fa fa-edit text-primary"></i></a>' + '<a href="#oderModalsee" data-toggle="modal" data-obj-id="' + item.objectId + '" class="see"><i class="si si-eye text-primary"></i></a>';
                            }));
                            console.log(ordersList);
                            table = $('#tableOrdersList').DataTable({
                                data: ordersList,
                                bDestroy: true,
                                bInfo: false,
                                paging: false,
                                bSort: false,
                                searching: false,
                                columns: [
                                    {
                                        data: 'objectId',
                                        title: 'id'
                                    }, {
                                        data: 'linkProperty',
                                        title: '预订的房源'
                                    }, {
                                        data: 'linkHost',
                                        title: '房东'
                                    }, {
                                        data: 'linkUser',
                                        title: '消费者'
                                    }, {
                                        data: 'totalAmount',
                                        title: '总金额'
                                    }, {
                                        data: 'statustx',
                                        title: '订单状态'
                                    }, {
                                        data: 'checkIn',
                                        title: '入住时间'
                                    }, {
                                        data: 'checkOut',
                                        title: '离开时间'
                                    }, {
                                        data: 'updatedAt',
                                        title: '更新时间'
                                    }, {
                                        data: 'createdAt',
                                        title: '创建时间'
                                    }, {
                                        data: 'action',
                                        title: '操作'
                                    }
                                ]
                            });
                        }else{
                            $('#tableOrdersList').html("暂无查询的对象");
                            $('#pagination-prop').empty();
                        }
                        $('.see').click(function () {
                            var  targetId = $(this).data('objId');
                            if (targetId) {
                                targetTr = $(this).parent().parent();
                                var  targetObj = _.find(ordersList, {
                                    'objectId': targetId
                                });
                                console.log('匹配到需要编辑的对象', targetObj);
                                if(targetObj.user.nickname){
                                    $(".nickname").text(targetObj.user.nickname);
                                }else{
                                    $(".nickname").text('暂无');
                                }
                                if(targetObj.user.email){
                                    $(".email").text(targetObj.user.email);
                                }else{
                                    $(".email").text('暂无');
                                }
                                if(targetObj.user.username){
                                    $(".username").text(targetObj.user.username);
                                }else{
                                    $(".username").text('暂无');
                                }
                                if(targetObj.user.objectId){
                                    $(".objectId").text(targetObj.user.objectId);
                                }else{
                                    $(".objectId").text('暂无');
                                }
                                if(targetObj.user.phoneNumber){
                                    $(".host_phoneNumber").text(targetObj.user.phoneNumber);
                                }else{
                                    $(".host_phoneNumber").text('暂无');
                                }
                                if(targetObj.property.address){
                                    var address=targetObj.property.address.country+targetObj.property.address.state+targetObj.property.address.city;
                                    $(".address").text(address);
                                }else{
                                    $(".address").text('暂无');
                                }
                                if(targetObj.property.objectId){
                                    $(".per_objectId").text(targetObj.property.objectId);
                                }else{
                                    $(".per_objectId").text('暂无');
                                }
                                if(targetObj.host.objectId){
                                    $(".hostid").text(targetObj.host.objectId);
                                }else{
                                    $(".hostid").text('暂无');
                                }
                                if(targetObj.user.phoneNumber){
                                    $(".phoneNumber").text(targetObj.user.phoneNumber);
                                }else{
                                    $(".phoneNumber").text('暂无');
                                }
                            }

                        });
                        targetTr = '';
                        $('.btn_edit').click(function () {
                            $(".order_refund").addClass("hidden");
                            var $button_group = $('.button_group');
                            $button_group.empty();
                            var propertyId, targetId, targetObj;
                            $('.order_form')[0].reset();
                            targetId = $(this).data('objId');
                            if (targetId) {
                                targetTr = $(this).parent().parent();
                                targetObj = _.find(ordersList, {
                                    'objectId': targetId
                                });

                                $(".remove_disabled").prop("disabled", true);
                                if (targetObj.status == 200) {
                                    $(".remove_disabled").prop("disabled", false);
                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary order_button" data-status="1000">接受订单</button>' +
                                        '<button type="button" class="btn btn-primary order_button" data-status="201">拒绝订单</button>';
                                    $button_group.append(data_bution);
                                } else if (targetObj.status == 501) {
                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary button order_button" data-dismiss="modal" data-status="502">人工处理</button>';
                                    $button_group.append(data_bution);
                                }
                                else if (targetObj.status == 1001) {

                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary button order_button" data-dismiss="modal" data-status="1002">人工处理</button>';
                                    $button_group.append(data_bution);
                                }
                                else if (targetObj.status == 1100) {

                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary button order_button" data-dismiss="modal" data-status="1101">接受取消</button>';
                                    $button_group.append(data_bution);
                                } else if (targetObj.status == 1102) {

                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary button order_button" data-dismiss="modal" data-status="1103">人工处理</button>';
                                    $button_group.append(data_bution);
                                    // }
                                    // else if(targetObj.status==2001){
                                    //   var data_bution='<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                    //       '<button type="button" class="btn btn-primary order_button refund" data-dismiss="modal" data-status="2002">同意申请</button>'+
                                    //       '<button type="button" class="btn btn-primary order_button refund" data-dismiss="modal" data-status="1600">拒绝申请</button>';
                                    //       $button_group.append(data_bution);
                                } else if (targetObj.status == 3000) {
                                    $(".remove_disabled").prop("disabled", false);
                                    $(".order_refund").empty();
                                    $(".order_refund").removeClass("hidden");
                                    $(".order_refund").append(
                                        " <div class='col-xs-12 m-b-10'>" +
                                        " <div class='form-group'> " +
                                        "<div class='col-xs-6'>" +
                                        " <div class='form-material'>" +
                                        " <input class='form-control' type='text' id='refund' name='oData[refund]'>" +
                                        " <label for=''>退还金额</label> " +
                                        "</div>" +
                                        "</div>" +
                                        "</div>" +
                                        "</div>"
                                       );
                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary order_button refund" data-dismiss="modal" data-status="4000">确认退房</button>';
                                    $button_group.append(data_bution);
                                } else if (targetObj.status == 4001) {
                                    var data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>' +
                                        '<button type="button" class="btn btn-primary order_button refund" data-dismiss="modal" data-status="4002">人工处理</button>';
                                    $button_group.append(data_bution);
                                }
                                else {
                                    data_bution = '<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>';
                                    $button_group.append(data_bution);
                                }
                                $('#editId').val(targetId);
                                console.log('匹配到需要编辑的对象', targetObj);
                                commonFn.fillToForm('order_form', targetObj);
                                propertyId = targetObj.objectId;
                                if (targetObj.property) {
                                    $("#order_prop").val(targetObj.property.name);
                                    $("#property_id").val(targetObj.property.objectId);
                                    $("#order_country").val(targetObj.property.address.country);
                                    $("#order_city").val(targetObj.property.city.name);
                                    console.log(targetObj.property.address);
                                    console.log(targetObj.property.address.country);
                                    $("#bedroom_count").val(targetObj.property.bedroomCount);
                                    $("#bathroom_count").val(targetObj.property.bathroomCount);
                                    $("#remark").val(targetObj.remark);

                                }
                                $("#checkIn").datepicker({
                                    language: "zh-CN",
                                    format: "yyyy-mm-dd",
                                    autoclose: true
                                });
                                $("#checkIn").datepicker('update', moment(targetObj.checkIn).format('YYYY-MM-DD'));
                                $("#checkOut").datepicker('update', moment(targetObj.checkOut).format('YYYY-MM-DD'));
                                $("#clean_fee").val(targetObj.CleanFee);
                                $("#service_fee").val(targetObj.ServiceFee);
                                $("#people_count").val(targetObj.peopleCount);
                                $("#order_status").val(targetObj.statustx);
                                $("#total_amount").val(targetObj.totalAmount);
                                //  $("#coupon").val(targetObj.coupon);
                            }

                            $('.order_button').click(function () {
                                var saveObj = {
                                    oData: {}
                                };

                                saveObj.oData.status = parseInt($(this).attr("data-status"));
                                if ($(this).attr("data-status") == "200") {
                                    saveObj.oData.CleanFee = $.trim($("#clean_fee").val());
                                    saveObj.oData.ServiceFee = $.trim($("#service_fee").val());
                                    saveObj.oData.checkIn = $.trim($("#checkIn").val());
                                    saveObj.oData.checkOut = $.trim($("#checkOut").val());
                                }
                                if ($(this).attr("data-status") == "4000") {
                                    saveObj.oData.turnBack = $.trim($("#refund").val());
                                }
                                if ($('#editId').val().length) {
                                    saveObj.oData.id = $('#editId').val();
                                }
                                console.log(saveObj);
                                if ($('.order_form').valid()) {
                                    console.log("jj");
                                    Parse.Cloud.run('manage_Order', saveObj).then(function (res) {
                                        console.log('dingdan', res);
                                        if (res.status == 1000) {
                                            newData = res.data.toJSON();
                                            if (saveObj.oData.status == 1000) {
                                                newData.statustx = "已确认的订单"
                                            }
                                            if (saveObj.oData.status == 201) {
                                                newData.statustx = "已取消的订单"
                                            }
                                            if (saveObj.oData.status == 1002) {
                                                newData.statustx = "已确认的订单"
                                            }
                                            if (saveObj.oData.status == 1101) {
                                                newData.statustx = "已取消的订单"
                                            }
                                            if (saveObj.oData.status == 1103) {
                                                newData.statustx = "已取消的订单"
                                            }
                                            if (saveObj.oData.status == 4000) {
                                                newData.statustx = "已完成的订单"
                                            }
                                            if (saveObj.oData.status == 4002) {
                                                newData.statustx = "已完成的订单"
                                            }
                                            newData['linkHost'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.host.objectId + ' " target="_blank">' + newData.host.nickname + '</a>';
                                            newData['linkUser'] = '<a href="' + config.frontEndUrl + 'user-show.html?userId=' + newData.user.objectId + ' " target="_blank">' + newData.user.nickname + '</a>';
                                            newData['linkProperty'] = '<a href="' + config.frontEndUrl + 'properties-detail.html?propertyId=' + newData.property.objectId + ' " target="_blank">' + newData.property.name + '</a>';
                                            newData['action'] = '<a href="#oderModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit"><i class="fa fa-edit text-primary"></i></a>';
                                            newData.action = '刷新页面后编辑';
                                            if (targetTr) {
                                                table.row(targetTr).data(newData).draw();
                                            } else {
                                                table.row.add(newData).draw();
                                            }
                                            return $('#oderModal').modal('hide');

                                        } else {
                                            swal('出错了...', error.message, 'error');
                                            return console.log('Error: ' + error.code + ' ' + error.message);
                                        }

                                    });
                                }

                            });
                        });
                        // $('.order_form').validate({
                        //     ignore: [],
                        //     errorClass: 'help-block text-right animated fadeInDown',
                        //     errorElement: 'div',
                        //     errorPlacement: function (error, e) {
                        //         jQuery(e).parents('.form-group > div').append(error);
                        //     },
                        //     highlight: function (e) {
                        //         var elem;
                        //         elem = jQuery(e);
                        //         elem.closest('.form-group').removeClass('has-error').addClass('has-error');
                        //         elem.closest('.help-block').remove();
                        //     },
                        //     success: function (e) {
                        //         var elem;
                        //         elem = jQuery(e);
                        //         elem.closest('.form-group').removeClass('has-error');
                        //         elem.closest('.help-block').remove();
                        //     },
                        //     rules: {
                        //         'oData[coupon]': {
                        //             required: true,
                        //             number: true
                        //         },
                        //         'oData[clean_fee]': {
                        //             required: true,
                        //             number: true
                        //         },
                        //         'oData[service_fee]': {
                        //             required: true,
                        //             number: true
                        //         },
                        //         'oData[checkIn]': {
                        //             required: true,
                        //         },
                        //         'oData[checkOut]': {
                        //             required: true,
                        //         },
                        //         'oData[refund]': {
                        //             required: true,
                        //         },
                        //     },
                        //     messages: {
                        //         'oData[coupon]': {
                        //             required: '请输入优惠费，且为数字',
                        //         },
                        //         'oData[clean_fee]': {
                        //             required: '请输入清洁费，且为数字'
                        //         },
                        //         'oData[service_fee]': {
                        //             required: '请输入服务费，且为数字'
                        //         },
                        //         'oData[checkIn]': {
                        //             required: '请选择入住日期'
                        //         },
                        //         'oData[checkOut]': {
                        //             required: '请选择离开日期'
                        //         },
                        //         'oData[refund]': {
                        //             required: '请输入退还金额，且为数字',
                        //         },
                        //     }
                        // });

                    },function(error) {
                        swal('出错了...', error.message, 'error');
                        return console.log('Error: ' + error.code + ' ' + error.message);
                    });
                }
            });

        }
        });

};
$('.order_form').validate({
    ignore: [],
    errorClass: 'help-block text-right animated fadeInDown',
    errorElement: 'div',
    errorPlacement: function (error, e) {
        jQuery(e).parents('.form-group > div').append(error);
    },
    highlight: function (e) {
        var elem;
        elem = jQuery(e);
        elem.closest('.form-group').removeClass('has-error').addClass('has-error');
        elem.closest('.help-block').remove();
    },
    success: function (e) {
        var elem;
        elem = jQuery(e);
        elem.closest('.form-group').removeClass('has-error');
        elem.closest('.help-block').remove();
    },
    rules: {
        'oData[coupon]': {
            required: true,
            number: true
        },
        'oData[clean_fee]': {
            required: true,
            number: true
        },
        'oData[service_fee]': {
            required: true,
            number: true
        },
        'oData[checkIn]': {
            required: true,
        },
        'oData[checkOut]': {
            required: true,
        },
        'oData[refund]': {
            required: true,
        },
    },
    messages: {
        'oData[coupon]': {
            required: '请输入优惠费，且为数字',
        },
        'oData[clean_fee]': {
            required: '请输入清洁费，且为数字'
        },
        'oData[service_fee]': {
            required: '请输入服务费，且为数字'
        },
        'oData[checkIn]': {
            required: '请选择入住日期'
        },
        'oData[checkOut]': {
            required: '请选择离开日期'
        },
        'oData[refund]': {
            required: '请输入退还金额，且为数字',
        },
    }
});
search();
var $order_objectId = $('#order_objectId');
var $order_proobjectId = $('#order_proobjectId');

var $order_nickname = $('#order_nickname');

var $order_checkIn = $('#order-checkIn');
var $order_checkOut = $('#order-checkOut');

var $order_statustc = $('#order_statustc');

var $order_usernickname = $('#order_usernickname');

var $order_totalAmount = $('#order_totalAmount');
$(".search").unbind().click(function () {
   var  searchProp = {
       oData:{
       }
   };
    if($order_objectId.val()!=''){
        searchProp.oData.objectId=$order_objectId.val();
    }
    if($order_checkIn.val()!=''){
        searchProp.oData.checkIn=$order_checkIn.val();
    }
    if($order_checkOut.val()!=''){
        searchProp.oData.checkOut=$order_checkOut.val();
    }
    if($order_statustc.val()!=''){
        searchProp.oData.status=parseInt($order_statustc.val());
    }
    if($order_totalAmount.val()!=''){
        searchProp.oData.totalAmount=parseFloat($order_totalAmount.val());
    }
    if($order_proobjectId.val()!=''){
      //  searchProp.oData.property={};
        searchProp.oData.property=$order_proobjectId.val();
    }
    if($order_nickname.val()!=''){
       // searchProp.oData.host={};
        searchProp.oData.host=$order_nickname.val();
    }
    if($order_usernickname.val()!=''){
        //searchProp.oData.user={};
        searchProp.oData.user=$order_usernickname.val();
    }
    console.log('obj',searchProp);
  //  console.log('status',$order_status);
  search(searchProp,searchProp.oData);
});
$(".alldata").on('click',function () {
    $order_objectId.val('');
    $order_proobjectId.val('');
    $order_checkIn.val('');
    $order_checkOut.val('');
    $order_statustc.val('');
    $order_usernickname.val('');
    $order_totalAmount.val('');
    search();
});
