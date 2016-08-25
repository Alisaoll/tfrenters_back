console.log 'common.js'
$ ->
  $(".switch_btn").click ->
    str = $(@).data('target')
    $(".switch_box").hide()
    $(".#{str}").show()