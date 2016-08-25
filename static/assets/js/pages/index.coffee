$.getScript("assets/js/common.js")
serverUrl = 'http://rentals.toursforfun.com/'
appId = 'ParseExampleApplication'
$(".city_list").hide()
stopBubble = (e) ->
  if e and e.stopPropagation
    e.stopPropagation()
  else
    window.event.cancelBubble = true
  return
stopDefault = (e) ->
  if e and e.preventDefault
    e.preventDefault()
  else
    window.event.returnValue = false
  false
$ ->
  $(".overlay").delay(500).fadeOut()
  $(document).click ->
    $(".city_list").fadeOut()
  $("#select_destination").click (e) ->
    stopBubble(e)
    $(".city_list").fadeIn()
  $(".city_list").click (e) ->
    stopBubble(e)
  $(".city_list li a").click ->
    text = $(@).text()
    $("#select_destination").val(text)
    $(".city_list").fadeOut()
  $(".select_text li a").click ->
    text = $(@).text()
    $(".dropdown-toggle",@.parentNode.parentNode.parentNode).empty().text(text)
  $("#modal-city_list_xs .box li a").click ->
    $("#modal-city_list_xs .box li a").removeClass('label').removeClass('label-primary')
    $(@).addClass('label').addClass('label-primary')
    text = $(@).text()
    $("#search_xs_destination").val(text)
    $("#modal-city_list_xs").modal('hide')
  $("#modal-search_xs .dropdown-menu a").click ->
    text = $(@).text()
    $("#people_number_xs").val(text)
  if $(".greatest_hit:visible").size()>0
    ua = navigator.userAgent.toLowerCase()
    if ua.match(/iPad/i) is "ipad"
      $(".greatest_hit .img-options").css("transform","translateY(0)")
  $(".search_area .room_type .btn").click ->
    $(@).toggleClass('btn-default').toggleClass('btn-primary')
    $('i',@).toggle()
  $(".btns_area .btn").click ->
    $(".search_area").removeClass('full')
    $(".search_area .btns_area").hide()
    $(".search_area .more_area").slideUp()
  $(".search_area_more").click ->
    $(".search_area").addClass('full')
    $(".search_area .btns_area").show()
    $(".search_area .more_area").slideDown()
  $(".top_one .fa").click ->
    $(".fa",@.parentNode).toggleClass('dn')
    $(".more_item",@.parentNode.parentNode).slideToggle()
  $(".fill_input ul li a").click ->
    t = $(@).text()
    $(".dropdown-toggle input",@.parentNode.parentNode.parentNode).val(t)
