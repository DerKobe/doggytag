$ ->
  if $('body#pages-show').length > 0
    editor = ace.edit('ace-editor')

    editor.setTheme('ace/theme/chrome')
    editor.setPrintMarginColumn 1000
    editor.getSession().setUseWrapMode(true)
    editor.renderer.setShowGutter(false)

    sharejs.open "text_#{window.current_page_token}", 'text', 'http://doggytag.net:8000/channel', (error, doc)->
      doc.attach_ace editor
      editor.focus()

    height_update_function = =>
      screen_length = editor.getSession().getScreenLength()
      screen_length = 15 if screen_length < 15
      newHeight = screen_length * editor.renderer.lineHeight + editor.renderer.scrollBar.getWidth()

      $ace_editor = $('#ace-editor')
      $ace_editor.height(newHeight.toString() + 'px')
      $ace_editor.closest('.component').find('.content-bar').height((newHeight+13).toString() + 'px')

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

    sharejs.open "chat_#{window.current_page_token}", 'json', 'http://doggytag.net:8000/channel', (error, doc)->
      $chat = $('#chat').show()
      $chat_input = $chat.find('input')

      # user data
      $user = $('#user')

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
        title = "<span class=\"name\">#{_.escape message.name}</span> schrieb um #{_.escape message.time}"
        if message.name == $user.data('name')
          toastr.info(_.escape(message.text), title)
        else
          toastr.success(_.escape(message.text), title)

      if (chat_history = chat.get()).length > 0
        _(chat_history).slice(0,15).reverse().each (message)=>show_chat_message(message)

      # new message?
      doc.on 'change', (op)=>
        name = op[0].li.name
        text = op[0].li.text
        time = op[0].li.time

        if op?[0].p[0] == 'chat'
          show_chat_message({name:name, text:text, time:time})

      $chat_input.on 'keydown', (event)=>
        if event.keyCode == 13 || event.keyCode == 27
          event.preventDefault()
          message = {
            name: $user.data('name'),
            text: $chat_input.val(),
            time: moment().format('H:mm')
          }
          chat.insert(0, message) if event.keyCode == 13 && $chat_input.val('') != ''
          $chat_input.val('').focus()

      $chat.find('a').on 'click', (event)->
        event.preventDefault()
        toastr.clear()