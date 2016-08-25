/**
 * Created by Alisa on 2016/7/11.
 *
 */

Parse.Cloud.run('manage_searchCustomize').then(function(res) {
    var table;
    var totalPages = res.data.count;
    if (totalPages < 1) {
        $('#pagination-prop').empty();
        $('#tableOrdersList').html('暂无匹配的对象');
    } else {
        $('#tableOrdersList').empty();
        return $('#pagination-prop').empty().removeData("twbs-pagination").off("page").twbsPagination({
            totalPages: Math.ceil(totalPages / 20),
            visiblePages: 10,
            onPageClick: function (event, page) {
                var searchProp;
                console.log('page on click', event, page);
                searchProp = {
                    oOption: {
                        nSkip: (page - 1) * 20
                    },
                };
              return  Parse.Cloud.run('manage_searchCustomize', searchProp).then(function(res) {
                    console.log('11111111',res);
                    list = [];
                    _(res.data.list.forEach(function(item) {
                        item= item.toJSON();
                        item.createdAt = moment(item.createdAt).format('LLL');
                        item.updatedAt = moment(item.updatedAt).format('LLL');
                        item['action'] = '<a href="#propertyModal" data-toggle="modal" data-obj-id="' + item.objectId + '" class="btn_edit m-r-10"><i class="fa fa-edit text-primary"></i></a><a href="#;" data-obj-id="' + item.objectId + '" class="btn_remove"><i class="fa fa-trash text-danger"></i></a>';
                        return list.push(item);
                    }));
                    table = $("#tablePropertiesList").DataTable({
                        data:list,
                        bDestroy: true,
                        bInfo: false,
                        paging: false,
                        searching:false,
                        bSort: false,
                        columns: [
                            {
                                data: 'objectId',
                                title: 'id'
                            }, {
                                data: 'sName',
                                title: '姓名'
                            }, {
                                data: 'nPhone',
                                title: '手机号'
                            }, {
                                data: 'nWeChat',
                                title: '微信号'
                            }, {
                                data: 'sEmail',
                                title: 'Email'
                            },
                            {
                                data: 'createdAt',
                                title: '创建时间'
                            },
                            {
                                data: 'updatedAt',
                                title: '更新时间'
                            },
                            {
                                data: 'action',
                                title: '操作'
                            }
                        ]
                    });


                    $('.btn_edit').unbind().click(function() {
                        var targetId, targetObj;
                        targetId = $(this).data('objId');
                        aImages = [];
                        if (targetId) {
                            targetObj = _.find(list, {
                                'objectId': targetId
                            });
                            $('#editId').val(targetId);
                            console.log('匹配到需要编辑的对象', targetObj);

                            $(".custorm_sname").text(targetObj.sName);
                            $(".custorm_nphone").text(targetObj.nPhone);
                            $(".custorm_nwechat").text(targetObj.nWeChat);
                            $(".custorm_semail").text(targetObj.sEmail);
                            $(".custorm_sremark").text(targetObj.sRemark);
                            $(".dCheckIn").text(targetObj.dCheckIn);
                            $(".dCheckOut").text(targetObj.dCheckOut);
                            $(".nBudget").text(targetObj.nBudget);
                            $(".sPath").text(targetObj.sPath);
                            $(".sHelp").text(targetObj.sHelp);
                            $(".sDestination").text(targetObj.sDestination);
                            $(".nPeople").text(targetObj.nPeople);

                        }
                    });
                },function(error) {
                  swal('出错了...', error.message, 'error');
                  return console.log('Error: ' + error.code + ' ' + error.message);
              });

            }
        });
    }
},function(error) {
    swal('出错了...', error.message, 'error');
    return console.log('Error: ' + error.code + ' ' + error.message);
});


