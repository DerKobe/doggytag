$ ->
  if $('#ace-editor').length > 0
    editor = ace.edit 'ace-editor'
    editor.setTheme 'ace/theme/chrome'
    editor.setPrintMarginColumn 1000

    sharejs.open "channel_#{window.current_page_token}", 'text', "http://bigmac.local:8000/channel", (error, doc)->
      doc.attach_ace editor
      editor.focus()