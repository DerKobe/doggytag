module PagesHelper

  def set_title(title)
    title = '' if title.nil?
    parts = title.split ' '
    black = parts.shift
    blue = parts.join ' '
    @title = { black: black, blue: blue }
  end

end
