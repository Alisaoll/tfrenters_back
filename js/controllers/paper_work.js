/**
 * Created by Alisa on 2016/7/11.
 */
Parse.Cloud.run('manage_searchPaperWork').then(function(res) {
    var editFn, table, targetTr, usersList;
    var totalPages = res.data.count;
    console.log('manage_getUserList success', res);
    return $('#pagination-prop').empty().removeData("twbs-pagination").off("page").twbsPagination({
        totalPages: Math.ceil(totalPages / 20),
        visiblePages: 10,
        onPageClick: function (event, page) {
            var searchProp;
            console.log('page on click', event, page);
            searchProp = {
                oOption: {
                    nSkip: (page - 1) * 20
                }
            };
            return Parse.Cloud.run('manage_searchPaperWork', searchProp).then(function(res) {
                var newData;
                var totalPages=15;
                console.log("www",res);

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
                    // "aaSorting": [[6, "desc"]],
                    bSort: false,
                    searching:false,
                    columns: [
                        {
                            data: 'objectId',
                            title: 'id'
                        }, {
                            data: 'title',
                            title: '标题'
                        }, {
                            data: 'type',
                            title: '类型'
                        },
                        {
                            data: 'status',
                            title: '状态'
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
                var targetId;
                $('.btn_edit').unbind().click(function() {
                    var $summernotePaper=$('#summernotePaper'),
                        $paper_title=$('#paper_title'),
                        $paper_tag=$('#paper_tag');
                    $summernotePaper.summernote('destroy');
                    $summernotePaper.empty();
                    $paper_title.val('');
                    $('.tagsinput .tag').remove();
                    $paper_tag.val('');
                    $paper_tag.tagsInput({
                        height:"36px",
                        width:"405px"
                    });

                    var targetObj;
                    targetId = $(this).data('objId');
                    aImages = [];
                    $summernotePaper.summernote({
                        height: 650
                    });

                    if (targetId) {
                        $summernotePaper.summernote('destroy');
                        $summernotePaper.empty();
                        targetObj = _.find(list, {
                            'objectId': targetId
                        });
                        targetTr = $(this).parent().parent();
                        console.log('匹配到需要编辑的对象', targetObj);
                        if (targetObj.content) {
                            $('#summernotePaper').html(targetObj.content);
                        }
                        $summernotePaper.summernote({
                            height: 650
                        });
                        $paper_title.val(targetObj.title);
                        $('#paper_type').val(targetObj.type);
                        $('#paper_status').val(targetObj.status);
                        $paper_tag.addTag(targetObj.tag);
                        // }
                    }

                });
                $('.btn_save').unbind().click(function() {
                    var tag=$(".tag span");
                    var a=[];
                    for(var i=0;i<tag.length;i++){
                        a.push($(tag[i]).text().trim());
                    }
                    console.log(a);
                    var obj={
                        oData:{}
                    };
                    obj.oData.objectId=targetId;
                    obj.oData.title=$('#paper_title').val();
                    obj.oData.type=$('#paper_type').val();
                    obj.oData.content=$('#summernotePaper').summernote('code');
                    obj.oData.status= parseInt($('#paper_status').val());
                    obj.oData.tag=a;
                    console.log(obj);
                    if ($('.property_form').valid()) {
                        return Parse.Cloud.run('manage_paperWork', obj).then(function (res) {
                            $('.btn_save').prop('disabled', false);
                            console.log(res);
                            newData = res.data.toJSON();
                            console.log('manage_paperWork success', newData);
                            aImages = [];
                            newData.createdAt = moment(newData.createdAt).format('LLL');
                            newData.updatedAt = moment(newData.updatedAt).format('LLL');
                            newData['action'] = '<a href="#propertyModal" data-toggle="modal" data-obj-id="' + newData.objectId + '" class="btn_edit m-r-10"><i class="fa fa-edit text-primary"></i></a><a href="#;" data-obj-id="' + newData.objectId + '" class="btn_remove"><i class="fa fa-trash text-danger"></i></a>';
                            newData.action = '刷新页面后编辑';
                            if (targetTr) {
                                if (newData.Status ===1000) {
                                    table.row(targetTr).remove().draw();
                                } else {
                                    table.row(targetTr).data(newData).draw();
                                }
                            } else {
                                table.row.add(newData).draw();
                            }
                            $('#propertyModal').modal('hide');
                        });
                    }
                });
                $('.btn_remove').click(function () {
                    //web_addUserFavo/web_removeUserFavo/web_getUserFavo
                    Parse.Cloud.run('web_removeUserFavo', {propId:"TTnXywPq4F"
                    }).then(function(res) {
                        console.log(res);
                    });
                })

                $('.property_form').validate({
                    ignore: [],
                    errorClass: 'help-block text-right animated fadeInDown',
                    errorElement: 'div',
                    errorPlacement: function(error, e) {
                        jQuery(e).parents('.form-group > div').append(error);
                    },
                    highlight: function(e) {
                        var elem;
                        elem = jQuery(e);
                        elem.closest('.form-group').removeClass('has-error').addClass('has-error');
                        elem.closest('.help-block').remove();
                    },
                    success: function(e) {
                        var elem;
                        elem = jQuery(e);
                        elem.closest('.form-group').removeClass('has-error');
                        elem.closest('.help-block').remove();
                    },
                    rules: {
                        'oData[title]': {
                            required: true,
                            minlength: 2
                        },
                        'oData[tag]': {
                            required: true,
                        },
                        'oData[status]': {
                            required: true,
                            number: true
                        },
                    },
                    messages: {
                        'oData[title]': {
                            required: '请输入文案标题',

                            minlength: '文案标题应该至少有两个字'
                        },
                        'oData[tag]': {
                            required: '必须指定一个文案的标签'
                        },
                        'oData[status]': {
                            required: '必须选择,且为数字'
                        },
                    }
                }),function(error) {
                    swal('出错了...', error.message, 'error');
                    return console.log('Error: ' + error.code + ' ' + error.message);
                };

            });
        }
    });
});



