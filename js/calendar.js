var AppCalendar = function() {

    return {
        //main function to initiate the module
        init: function() {
            this.initCalendar();
        },

        initCalendar: function() {

            if (!jQuery().fullCalendar) {
                return;
            }

            var date = new Date();
            var d = date.getDate();
            var m = date.getMonth();
            var y = date.getFullYear();

            var h = {};

            if (App.isRTL()) {
                if ($('#calendar').parents(".portlet").width() <= 720) {
                    $('#calendar').addClass("mobile");
                    h = {
                        right: 'title, prev, next',
                        center: '',
                        left: 'agendaDay, agendaWeek, month, today'
                    };
                } else {
                    $('#calendar').removeClass("mobile");
                    h = {
                        right: 'title',
                        center: '',
                        left: 'agendaDay, agendaWeek, month, today, prev,next'
                    };
                }
            } else {
                if ($('#calendar').parents(".portlet").width() <= 720) {
                    $('#calendar').addClass("mobile");
                    h = {
                        left: 'title, prev, next',
                        center: '',
                        right: 'today,month,agendaWeek,agendaDay'
                    };
                } else {
                    $('#calendar').removeClass("mobile");
                    h = {
                        left: 'title',
                        center: '',
                        right: 'prev,next,today,month,agendaWeek,agendaDay'
                    };
                }
            }

            var initDrag = function(el) {
                // create an Event Object (http://arshaw.com/fullcalendar/docs/event_data/Event_Object/)
                // it doesn't need to have a start or end
                var eventObject = {
                    title: $.trim(el.text()) // use the element's text as the event title
                };
                // store the Event Object in the DOM element so we can get to it later
                el.data('eventObject', eventObject);
                // make the event draggable using jQuery UI
                el.draggable({
                    zIndex: 999,
                    revert: true, // will cause the event to go back to its
                    revertDuration: 0 //  original position after the drag
                });
            };

            var addEvent = function(title) {
                title = title.length === 0 ? "Untitled Event" : title;
                var html = $('<div class="external-event label label-default">' + title + '</div>');
                jQuery('#event_box').append(html);
                initDrag(html);
            };

            $('#external-events div.external-event').each(function() {
                initDrag($(this));
            });

            $('#event_add').unbind('click').click(function() {
                var title = $('#event_title').val();
                addEvent(title);
            });

            //predefined events
            $('#event_box').html("");
            addEvent("My Event 1");
            addEvent("My Event 2");
            addEvent("My Event 3");
            addEvent("My Event 4");
            addEvent("My Event 5");
            addEvent("My Event 6");


            function addDay(date,number){
                var a = new Date(date);
                a = a.valueOf();
                a = a + number * 24 * 60 * 60 * 1000;
                a = new Date(a);
                return a;
            }

            function GMT_TO_UTC(dd){
                var a = new Date(dd);
                a = a.valueOf();
                a = a +  8 * 60 * 60 * 1000;
                a = new Date(a);
                return a;
            }

            //处理时间 格式为yy-mm-dd
            function timetall(time1){
                if(time1) {
                    date = time1.getDate();
                    month = time1.getMonth();
                    month = month + 1;
                    if (month <= 9) {
                        month = "0" + month;
                    }
                    year = time1.getFullYear();
                    var time = year + "-" + month + "-" + date;
                    return time;
                }
            }
            //显示一段时间
            function show(value1,value2,arr){
                if(value2==null) {
                    value2=value1;
                }
                var getDate = function (str) {
                    var tempDate = new Date();
                    var list = str.split("-");
                    tempDate.setFullYear(list[0]);
                    tempDate.setMonth(list[1] - 1);
                    tempDate.setDate(list[2]);
                    return tempDate;

                }
                var date1 = getDate(value1);
                var date2 = getDate(value2);
                if (date1 > date2) {
                    var tempDate = date1;
                    date1 = date2;
                    date2 = tempDate;
                }
                //   date1.setDate(date1.getDate());

                while (!(date1.getFullYear() == date2.getFullYear() && date1.getMonth() == date2.getMonth() && date1.getDate() == date2.getDate())) {
                    var res = date1.getFullYear() + "-" + (date1.getMonth() + 1) + "-" + date1.getDate();
                    arr.push(res);
                    date1.setDate(date1.getDate() + 1);


                }


            }
            $("#button").click(function(){
                var time_start=[],time_end=[];
                var events=[];
                var res=$('#calendar').fullCalendar('clientEvents');
                _(res.forEach(function(item) {
                    console.log("item",item);
                    // if(item.end==null){
                    //     item._end=item._start._d
                    //     time_start.push(item._start._d);
                    //     events.push({
                    //         start:timetall(item._start._d),
                    //         end:timetall(item._end)
                    //     });
                    // }else {
                    time_start.push(item._start._d);
                    events.push({
                        start:timetall(item._start._d),
                        end:timetall(item._end._d)
                    });
                    // }
                    console.log('events',events);
                }));
                // for(var i=0;i<res.length;i++){
                //     if(res[i].end==null){
                //         res[i]._end=res[i]._start._d
                //         time_start.push(res[i]._start._d);
                //         events.push({
                //             start:timetall(res[i]._start._d),
                //             end:timetall(res[i]._end)
                //         });
                //     }else {
                //         time_start.push(res[i]._start._d);
                //         events.push({
                //             start:timetall(res[i]._start._d),
                //             end:timetall(res[i]._end._d)
                //         });
                //     }
                //
                // }
                console.log(res);
                var resarr = [];
                for(var i=0;i<events.length;i++){
                    show(events[i].start,events[i].end,resarr);
                }
                alert("nih");
                console.log(resarr);
                console.log(s);
            });
            $("#all").click(function(){
                alert("是否全部清除");
                $('#calendar').fullCalendar('removeEvents');
            });
            $("#add").click(function(){
                var start1=$('#full_start').val();
                var end1=$('#full_end').val();
                var title1=$('#full_title').val();
                var startdate_ = GMT_TO_UTC(new Date(start1));
                var enddate_ = GMT_TO_UTC(new Date(end1));
                console.log("date",enddate_>startdate_);
                var today_date = new Date();
                if(startdate_ < today_date){
                    alert("起始日期不能小于当天日期！");
                    return;
                }
                if(startdate_ > enddate_){
                    alert("起始日期不能大于结束日期！");
                    return;
                }
                var events=[];
                var res=$('#calendar').fullCalendar('clientEvents');

                if(start1)
                    for(var i=0;i<res.length;i++){
                        events.push({
                            start:timetall(res[i]._start._d),
                            end:timetall(res[i]._end?res[i]._end._d:res[i]._start._d) // will be parsed
                        });
                    }
                for(var i=0;i<events.length;i++){

                    var temp_start = GMT_TO_UTC(new Date(events[i].start.replace(/-/g,"/")));
                    var temp_end_ = events[i].end?events[i].end:events[i].start;
                    var temp_end = GMT_TO_UTC(new Date(temp_end_.replace(/-/g,"/")));
                    if(startdate_ >= temp_start && startdate_ <= temp_end){
                        startdate_ = temp_start;
                    }
                    if(enddate_ >= temp_start && enddate_ <= temp_end){
                        enddate_ = temp_end;
                    }
                }

                $('#calendar').fullCalendar('removeEvents', function (event) {
                    console.log(event);
                    var temp_date_end =  event.end?event.end._d:event.start._d;
                    if(startdate_ <= event.start._d && enddate_ >= temp_date_end){
                        return true;
                    }
                    return false;
                });
                $('#calendar').fullCalendar('renderEvent',
                    {
                        title: title1,
                        start: startdate_,
                        end: enddate_,
                        allDay: true,
                        id: date
                    });




            });
            $("#if_calendar").click(function () {
                $(".show-calendar").toggle();
                setTimeout($('#calendar').fullCalendar({
                    header: {
                        right: 'prev,next',
                        center: 'title',
                        left: 'month'
                    },
                    defaultView: 'month', // change default view with available options from http://arshaw.com/fullcalendar/docs/views/Available_Views/
                    editable: true,
                    droppable: true, // this allows things to be dropped onto the calendar !!!
                    monthNames: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                    monthNamesShort: ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"],
                    dayNames: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
                    dayNamesShort: ["周日", "周一", "周二", "周三", "周四", "周五", "周六"],
                    today: ["今天"],
                    firstDay: 1,
                    buttonText: {
                        today: '今天',
                        month: '月',
                        week: '周',
                        day: '日',
                        prev: '上一月',
                        next: '下一月'
                    },
                    events: [
                        {
                            title: '日期不可用',
                            start: '/07/27/2016/',
                            end: '/07/30/2016/',
                            allDay: true
                        },
                        {
                            title: '日期不可用',
                            start: '2016-06-23',
                            end: '2016-06-25'
                        },
                        {
                            title: '日期不可用',
                            start: '06/30/2016/',
                            end: '07/09/2016/',
                            allDay: true
                        }
                    ],
                    dayClick: function (date, event, jsEvent, resourceObj) {
                        var today_date = new Date();
                        var day_enddate = addDay(date, 1);
                        if (date > today_date) {
                            var events = $('#calendar').fullCalendar('clientEvents', function (event) {
                                var eventStart = event.start._d;
                                var eventEnd = event.end ? addDay(event.end._d, -1) : eventStart;
                                var theDate = date._d;
                                return (eventStart <= theDate && (eventEnd >= theDate) && !(eventStart < theDate && (eventEnd == theDate))) || (eventStart == theDate && (eventEnd === null));

                            });
                            console.log("evnet", events);
                            if (events.length == 0) {
                                $('#calendar').fullCalendar('renderEvent',
                                    {
                                        title: '日期不可用',
                                        start: date,
                                        end: day_enddate,
                                        allDay: true

                                    });

                            } else {
                                if (events[0].start._d < today_date) {
                                    alert("今天之前的进程不能删除");
                                } else {
                                    $('#calendar').fullCalendar('removeEvents', events[0]._id);//删除事件
                                }

                            }


                        }
                        else {
                            alert("今天之前的时间无法添加日程");
                        }
                    }
                }),500) ;

            });
            $('.input-daterange').datepicker({
                language: "zh-CN",
                startDate: new Date(),
                autoclose: true
            });

            $('#full_start').datepicker().on('hide', function () {
                var dateRange1_1, lessSelect;
                dateRange1_1 = $('#full_start').datepicker('getDate');
                if (dateRange1_1) {
                    lessSelect = moment(dateRange1_1).add(1, 'days').format('YYYY-MM-DD');
                    $('#full_end').datepicker('setDate', lessSelect);
                    return $('#full_end').datepicker('show');
                }

            })
        }

    };

}();

jQuery(document).ready(function() {
   AppCalendar.init();

console.log("hh");
    //$("#if_calendar").click(function () {alert(2)});
});