class String
  
  # Constantizes a string, changing it from snake_case or 'space case' to
  # TitleCase, however necessary
  def constantize
    str = self
    str = str.gsub /\s/, '_'
    str = str.gsub(/(^|_)(\w)/) { "#{$2.capitalize}" }
  end
  
end