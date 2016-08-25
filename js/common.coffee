config =
  domain: 'https://rentals.toursforfun.com/parse'
  appId: 'ParseExampleApplication'
  javascriptKey: 'JsecXZ5jk83EaQkBJ2Bg7kb'
  qiniuDomain: 'http://7xum8i.com1.z0.glb.clouddn.com/'
  frontEndUrl: 'https://rentals.toursforfun.com/'
extraData = {
  amenitiesType: [
    '基础设施'
    '周边设施'
    '增值服务'
    '其他便利设施'
  ]
}
commonFn = {
  stopBubble: (e) ->
    if e and e.stopPropagation
      e.stopPropagation()
    else
      window.event.cancelBubble = true
    return

  stopDefault: (e) ->
    if e and e.preventDefault
      e.preventDefault()
    else
      window.event.returnValue = false
    false
  getScript: (url) ->
    $.ajax
      url: url
      dataType: 'script'
      async: false
    return
  urlParamToObj: ()->
    if location.search
      u = location.search
    else
      u = location.href
      u = u.slice(0, u.indexOf("#"))
    p = {}
    if -1 != u.indexOf("?")
      sear = u.slice(u.indexOf("?")+1).split("&")
      for item in sear
        do(item)->
          s = item.split("=")
          p[s[0]] = s[1]
    return p
  ###*
  # Function for transfer parse's Object to a plain object
  # @param {object} data The city id in user's data
  # @param {string} inc The included data witch need to operate
  # @return {object} Plain object
  # @example
  # transferData(data,"inc1 inc2 inc3")
  ###
  transferData: (data,inc) ->
    arr = []
    if inc
      arr = inc.split " "
    if _.isObject(data)
      if Array.isArray(data)
        DataRes = []
        _ data.forEach (mainItem) ->
          mainPlainObj = mainItem.toJSON()
          _ arr.forEach (incItem) ->
            find = _.keys mainPlainObj
            if find.indexOf(incItem) isnt -1
              incPlainObj = mainItem.get(incItem).toJSON()
              mainPlainObj[incItem] = incPlainObj
          DataRes.push mainPlainObj
        if DataRes.length >0
          return DataRes
        else
          return false
      else
        mainPlainObj = data.toJSON()
        _ arr.forEach (incItem) ->
          find = _.keys mainPlainObj
          if find.indexOf(incItem) isnt -1
            incPlainObj = data.get(incItem).toJSON()
            mainPlainObj[incItem] = incPlainObj
        return mainPlainObj
    else
      return '需要转换的对象并不是array或object'
  hbsRender: (selecter,hbs,dataJSON,callback,ext) ->
    extRes = '.hbs'
    dataRes = {}
    callbackRes = ->
      console.log "#{hbs} 渲染完成"
    if ext
      extRes = ext
    if dataJSON
      dataRes = dataJSON
    if callback
      callbackRes = callback
    $(selecter).loadFromTemplate
      template: hbs
      data: dataRes
      callback: callbackRes()
      extension : extRes,
  qiniuFn: ->
    Parse.Cloud.run('manage_getUploadToken').then (res) ->
      console.log 'token success',res
      $('#uptoken').val(res.data.token)
      $('#domain').val(config.qiniuDomain)
      Qiniu = new QiniuJsSDK()
      uploader = Qiniu.uploader(
        runtimes: 'html5,flash,html4'
        browse_button: 'pickfiles'
        container: 'container'
        drop_element: 'container'
        max_file_size: '10mb'
        flash_swf_url: 'bower_components/plupload/js/Moxie.swf'
        dragdrop: true
        chunk_size: '4mb'
        multi_selection: !(mOxie.Env.OS.toLowerCase() == 'ios')
        uptoken_func: ->
          $('#uptoken').val()
        domain: config.qiniuDomain
        get_new_uptoken: false
        unique_names: true
        auto_start: true
        log_level: 5
        init:
          'FilesAdded': (up, files) ->
            $('table').show()
            $('#success').hide()
            plupload.each files, (file) ->
              progress = new FileProgress(file, 'fsUploadProgress')
              progress.setStatus '等待...'
              progress.bindUploadCancel up
              return
            return
          'BeforeUpload': (up, file) ->
            progress = new FileProgress(file, 'fsUploadProgress')
            chunk_size = plupload.parseSize(@getOption('chunk_size'))
            if up.runtime == 'html5' and chunk_size
              progress.setChunkProgess chunk_size
            return
          'UploadProgress': (up, file) ->
            progress = new FileProgress(file, 'fsUploadProgress')
            chunk_size = plupload.parseSize(@getOption('chunk_size'))
            progress.setProgress file.percent + '%', file.speed, chunk_size
            return
          'UploadComplete': ->
            $('#success').show()
            return
          'FileUploaded': (up, file, info) ->
            progress = new FileProgress(file, 'fsUploadProgress')
            progress.setComplete up, info
            console.log '上传后',info
            res = $.parseJSON(info)
            aImages.push config.qiniuDomain + res.key
            return
          'Error': (up, err, errTip) ->
            $('table').show()
            progress = new FileProgress(err.file, 'fsUploadProgress')
            progress.setError()
            progress.setStatus errTip
            return
      )
      uploader.bind 'FileUploaded', ->
        console.log 'hello man,a file is uploaded'
        return
      $('#container').on('dragenter', (e) ->
        e.preventDefault()
        $('#container').addClass 'draging'
        e.stopPropagation()
        return
      ).on('drop', (e) ->
        e.preventDefault()
        $('#container').removeClass 'draging'
        e.stopPropagation()
        return
      ).on('dragleave', (e) ->
        e.preventDefault()
        $('#container').removeClass 'draging'
        e.stopPropagation()
        return
      ).on 'dragover', (e) ->
        e.preventDefault()
        $('#container').addClass 'draging'
        e.stopPropagation()
        return
      $('#show_code').on 'click', ->
        $('#myModal-code').modal()
        $('pre code').each (i, e) ->
          hljs.highlightBlock e
          return
        return
      $('body').on 'click', 'table button.btn', ->
        $(this).parents('tr').next().toggle()
        return

      getRotate = (url) ->
        if !url
          return 0
        arr = url.split('/')
        i = 0
        len = arr.length
        while i < len
          if arr[i] == 'rotate'
            return parseInt(arr[i + 1], 10)
          i++
        0

      $('#myModal-img .modal-body-footer').find('a').on 'click', ->
        img = $('#myModal-img').find('.modal-body img')
        key = img.data('key')
        oldUrl = img.attr('src')
        originHeight = parseInt(img.data('h'), 10)
        fopArr = []
        rotate = getRotate(oldUrl)
        if !$(this).hasClass('no-disable-click')
          $(this).addClass('disabled').siblings().removeClass 'disabled'
          if $(this).data('imagemogr') != 'no-rotate'
            fopArr.push
              'fop': 'imageMogr2'
              'auto-orient': true
              'strip': true
              'rotate': rotate
              'format': 'png'
        else
          $(this).siblings().removeClass 'disabled'
          imageMogr = $(this).data('imagemogr')
          if imageMogr == 'left'
            rotate = if rotate - 90 < 0 then rotate + 270 else rotate - 90
          else if imageMogr == 'right'
            rotate = if rotate + 90 > 360 then rotate - 270 else rotate + 90
          fopArr.push
            'fop': 'imageMogr2'
            'auto-orient': true
            'strip': true
            'rotate': rotate
            'format': 'png'
        $('#myModal-img .modal-body-footer').find('a.disabled').each ->
          `var imageMogr`
          watermark = $(this).data('watermark')
          imageView = $(this).data('imageview')
          imageMogr = $(this).data('imagemogr')
          if watermark
            fopArr.push
              fop: 'watermark'
              mode: 1
              image: 'http://www.b1.qiniudn.com/images/logo-2.png'
              dissolve: 100
              gravity: watermark
              dx: 100
              dy: 100
          if imageView
            height = undefined
            switch imageView
              when 'large'
                height = originHeight
              when 'middle'
                height = originHeight * 0.5
              when 'small'
                height = originHeight * 0.1
              else
                height = originHeight
                break
            fopArr.push
              fop: 'imageView2'
              mode: 3
              h: parseInt(height, 10)
              q: 100
              format: 'png'
          if imageMogr == 'no-rotate'
            fopArr.push
              'fop': 'imageMogr2'
              'auto-orient': true
              'strip': true
              'rotate': 0
              'format': 'png'
          return
        newUrl = Qiniu.pipeline(fopArr, key)
        newImg = new Image
        img.attr 'src', 'images/loading.gif'

        newImg.onload = ->
          img.attr 'src', newUrl
          img.parent('a').attr 'href', newUrl
          return

        newImg.src = newUrl
        false
      return
  fillToForm: (formName,data) ->
    if $("#{formName}").size() <1 and _.isObject(data)
      $inputs = $(".#{formName} input")
      $.each data, (key, value) ->
        $inputs.filter ->
          return key is this.id
        .val(value)
    else
      console.warn 'form不存在或供填充的data不是json'
  isLogin: ->
    currentUser = Parse.User.current()
    if currentUser
      currentUserInfo = currentUser.toJSON()
      extraData['currentUserInfo'] = currentUserInfo
      console.log '当前用户',extraData['currentUserInfo']
      $('.login_modal').hide()
    else
      $('.login_modal').show()
}
Swag.registerHelpers()
Parse.initialize config.appId, config.javascriptKey
Parse.serverURL = config.domain
commonFn.isLogin()
$.getJSON "data/IndexContent.json"
.done (indexRes) ->
  extraData['indexRes'] = indexRes
  $.getJSON "data/GlobalContent.json"
  .done (globalRes) ->
    extraData['globalRes'] = globalRes
    pageData =
      indexData: extraData.indexRes
      globalData: extraData.globalRes
      currentUserData: extraData['currentUserInfo']
    console.log 'pageData',pageData
    $('.nav-main .link').click ->
      $('.nav-main .link').removeClass('active')
      $(@).addClass('active')
      commonFn.stopDefault()
      tmpName = $(@).data('hbsTarget')
      ctrlName = _.camelCase(tmpName);
      console.log tmpName
      console.log ctrlName
      $('#main-container').hide().empty()
      Promise.resolve(commonFn.hbsRender('#main-container',tmpName)).then ->
        $('#main-container').fadeIn()
        console.log "after #{tmpName}"
    $('.text-click').click()
    $('.btn_log_out').click ->
      Parse.User.logOut().then ->
        extraData['currentUserInfo'] = {}
        $('.login_modal').show()
    $('.submit_login').click ->
      username = $('#login-username').val().trim()
      password = $('#login-password').val().trim()
      validateRes = $('.js-validation-login').valid()
      if validateRes is true
        Parse.User.logIn username, password,
          success: (user) ->
            currentUserInfo = commonFn.transferData(user)
            extraData['currentUserInfo'] = currentUserInfo
            $('.login_modal').hide()
          error: (user, error) ->
            swal '出错了...', error.message, 'error'
            console.log 'Error: ' + error.code + ' ' + error.message
            return