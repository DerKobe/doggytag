$ ->
  if $('body#pages-show').length > 0
    current_page_token = $('#page').data('token')

    editor = ace.edit('ace-editor')

    editor.setTheme('ace/theme/chrome')
    editor.setPrintMarginColumn 1000
    editor.getSession().setUseWrapMode(true)
    editor.renderer.setShowGutter(false)

    # -------------
    # --- A C E ---
    # -------------
    sharejs.open "text_#{current_page_token}", 'text', "#{$('body').data('host')}channel", (error, doc)->
      doc.attach_ace editor
      editor.focus()

    height_update_function = =>
      screen_length = editor.getSession().getScreenLength()
      screen_length = 15 if screen_length < 15
      new_height = screen_length * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()

      $ace_editor = $('#ace-editor')
      $ace_editor.height("#{new_height}px")
      $ace_editor.closest('.component').find('.content-bar').height("#{new_height}px")

      editor.resize()

    # Set initial size to match initial content
    height_update_function()

    # Whenever a change happens inside the ACE editor, update the size again
    editor.getSession().on('change', height_update_function)

    $('#components').on 'click', (event)->
      $target = $(event.target)
      if $target.parent().hasClass('toggle-component')
        event.preventDefault()
        $component = $target.closest('.component')
        $component.find('.content-bar').slideToggle 100

        editor.focus() if $component.find('#ace-editor').length > 0

        $target.parent().find('i').toggle()

    # user data
    $user = $('#user')

    # ---------------
    # --- C H A T ---
    # ---------------
    sharejs.open "chat_#{current_page_token}", 'json', "#{$('body').data('host')}channel", (error, doc)=>
      $chat = $('#chat').show()
      $chat_input = $chat.find('input')

      # options for that messages
      toastr.options = {
        timeOut: 0,
        extendedTimeOut: 0,
        tapToDismiss: false,
        fadeOut: 150
      }

      doc.set( { chat: [] } ) if doc.get() == null
      chat = doc.at('chat')

      show_chat_message = (message)=>
        time = moment(new Date(message.time * 1000))
        format = if moment().diff(time, 'days') == 0 then '[um] H:mm' else '[am] D.M.YYYY H:mm'

        title = "<span class=\"name\">#{_.escape message.name}</span> schrieb #{time.format(format)}"
        if message.name == $user.data('name')
          toastr.info(_.escape(message.text), title)
        else
          toastr.success(_.escape(message.text), title)

      if (chat_history = chat.get()).length > 0
        _(chat_history).slice(0,15).reverse().each (message)=>show_chat_message(message)

      # new message?
      doc.on 'change', (op)=>
        _(op).each (val)=>
          show_chat_message(name: val.li.name, text: val.li.text, time: moment(val.li.time)) if val.p[0] == 'chat'

      $chat_input.on 'keydown', (event)=>
        if event.keyCode == 13 || event.keyCode == 27
          event.preventDefault()
          message = {
            name: $user.data('name'),
            text: $chat_input.val(),
            time: moment().unix()
          }
          chat.insert(0, message) if event.keyCode == 13 && $chat_input.val('') != ''
          $chat_input.val('').focus()

      $chat.find('a').on 'click', (event)->
        event.preventDefault()
        toastr.clear()

    # ---------------------------------
    # --- O N L I N E   S T A T U S ---
    # ---------------------------------
    sharejs.open "online_#{current_page_token}", 'json', "#{$('body').data('host')}channel", (error, doc)=>
      doc.set( { online: {} } ) if doc.get() == null
      online = doc.at('online')

      $status_bar = $('#online-users')
      $status_bar.show()

      # update users online status bar
      render_users_online_status_bar = =>
        statuses = online.get()
        $user_labels = $status_bar.find('.users')
        $user_labels.empty()
        _(statuses).each (timestamp, name)=>
          now = moment().format('X')
          if timestamp > now - 10
            label = if name == $user.data('name') then 'info' else 'success'
            $user_labels.append( $("<div class=\"label label-#{label}\">#{name}</div>") )

      doc.on 'change', render_users_online_status_bar

      update_online_status = =>
        user = $user.data('name')
        my_status = online.at(user)
        my_status.set(moment().format('X'))

      update_online_status()
      setInterval(update_online_status, 5000);

    # ---------------------------
    # --- P A G E   T I T L E ---
    # ---------------------------
    $page_title = $('#page-title')

    # save new page name and change it live
    set_page_title = (title)=>
      title = _.str.trim(title)
      parts = title.split(' ')
      black = $("<span class=\"brand\">#{parts.shift()} </span>")
      blue  = $("<span class=\"doggy-blue\">#{parts.join(' ')}</span>")
      input = $("<span class=\"input\" contenteditable=\"true\">#{title}</span>")
      $page_title.empty().append(black).append(blue).append(input).show().find('span.input').hide()

    set_page_title $('#page').data('name')

    save_page_title = (title)=>
      title = _.str.trim(title)
      $.ajax(
        url: "/pages/#{$('#page').data('token')}"
        complete: (response)=>
          set_page_title response.responseJSON.name
        data: { name: title }
        error: (response)=>
          console.err response
          set_page_title $('#page').data('name')
        type: 'POST'
      )
      set_page_title(title)

    # clicking page name triggers editing it
    $page_title
      .on('click', =>
        $page_title.find('.brand, .doggy-blue').hide()
        $page_title.find('span.input').show().focus()

      ).on('keydown', 'span.input', (event)->
        if event.keyCode == 13
          event.preventDefault()
          $(event.target).blur()
        else if event.keyCode == 27
          set_page_title $('#page').data('name')

      ).on('paste', 'span.input', (event)->
        event.preventDefault() if $(event.target).hasClass('input')

      ).on('blur', 'span.input', (event)=>
        event.preventDefault()
        save_page_title(event.target.innerText)
      )