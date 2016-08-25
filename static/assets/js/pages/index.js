// Generated by CoffeeScript 1.10.0
var appId, serverUrl, stopBubble, stopDefault;

$.getScript("assets/js/common.js");

serverUrl = 'http://rentals.toursforfun.com/';

appId = 'ParseExampleApplication';

$(".city_list").hide();

stopBubble = function(e) {
  if (e && e.stopPropagation) {
    e.stopPropagation();
  } else {
    window.event.cancelBubble = true;
  }
};

stopDefault = function(e) {
  if (e && e.preventDefault) {
    e.preventDefault();
  } else {
    window.event.returnValue = false;
  }
  return false;
};

$(function() {
  var ua;
  $(".overlay").delay(500).fadeOut();
  $(document).click(function() {
    return $(".city_list").fadeOut();
  });
  $("#select_destination").click(function(e) {
    stopBubble(e);
    return $(".city_list").fadeIn();
  });
  $(".city_list").click(function(e) {
    return stopBubble(e);
  });
  $(".city_list li a").click(function() {
    var text;
    text = $(this).text();
    $("#select_destination").val(text);
    return $(".city_list").fadeOut();
  });
  $(".select_text li a").click(function() {
    var text;
    text = $(this).text();
    return $(".dropdown-toggle", this.parentNode.parentNode.parentNode).empty().text(text);
  });
  $("#modal-city_list_xs .box li a").click(function() {
    var text;
    $("#modal-city_list_xs .box li a").removeClass('label').removeClass('label-primary');
    $(this).addClass('label').addClass('label-primary');
    text = $(this).text();
    $("#search_xs_destination").val(text);
    return $("#modal-city_list_xs").modal('hide');
  });
  $("#modal-search_xs .dropdown-menu a").click(function() {
    var text;
    text = $(this).text();
    return $("#people_number_xs").val(text);
  });
  if ($(".greatest_hit:visible").size() > 0) {
    ua = navigator.userAgent.toLowerCase();
    if (ua.match(/iPad/i) === "ipad") {
      $(".greatest_hit .img-options").css("transform", "translateY(0)");
    }
  }
  $(".search_area .room_type .btn").click(function() {
    $(this).toggleClass('btn-default').toggleClass('btn-primary');
    return $('i', this).toggle();
  });
  $(".btns_area .btn").click(function() {
    $(".search_area").removeClass('full');
    $(".search_area .btns_area").hide();
    return $(".search_area .more_area").slideUp();
  });
  $(".search_area_more").click(function() {
    $(".search_area").addClass('full');
    $(".search_area .btns_area").show();
    return $(".search_area .more_area").slideDown();
  });
  $(".top_one .fa").click(function() {
    $(".fa", this.parentNode).toggleClass('dn');
    return $(".more_item", this.parentNode.parentNode).slideToggle();
  });
  return $(".fill_input ul li a").click(function() {
    var t;
    t = $(this).text();
    return $(".dropdown-toggle input", this.parentNode.parentNode.parentNode).val(t);
  });
});