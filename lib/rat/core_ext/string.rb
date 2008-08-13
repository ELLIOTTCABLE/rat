require 'stringray'

class String
  include StringRay
  
  # Constantizes a string, changing it from snake_case or 'space case' to
  # TitleCase, however necessary
  def constantize
    str = self
    str = str.gsub /\s/, '_'
    str = str.gsub(/(^|_)(\w)/) { "#{$2.capitalize}" }
  end
  
  def /(o)
    File.join(self, o.to_s)
  end
  
  def indent spaces
    if spaces.respond_to? :to_s # duck,
      self.split("\n").map {|s| [spaces, s].join }.join("\n")
    elsif spaces.respond_to? :to_i # duck,
      self.split("\n").map {|s| [(' ' * spaces), s].join }.join("\n")
    else # goose!
      raise ArgumentError, "#{spaces} is neither string-ish nor numeric-ish"
    end
  end
  
  # Ruby 1.8's #length doesn't like multibyte Unicode. Thanks Mikael Høilund!
  def length
    self.scan(/./um).size
  end
  
  # Simply returns an array of two string pieces split at +length+.
  def split_at length
    self.scan /.{1,#{length}}/
  end
  
  # Wraps a string, *intelligently*
  def wrap width, min = nil
    raise ArgumentError, "#{width} is not numeric-ish" unless width.respond_to? :to_i
    min ||= (width.to_i * 0.75).to_i # Default to about a third of the full width
    raise ArgumentError, "#{min} is not numeric-ish" unless min.respond_to? :to_i
    
    
    self.inject([""]) do |wrapped, word|
      #puts "word: #{word.inspect}, current line: #{wrapped.last.inspect}"
      # If we're still short enough to fit the word, do so
      if wrapped.last.length + word.rstrip.length <= width
        #puts "- new length #{wrapped.last.length + word.rstrip.length} (#{wrapped.last.length} + #{word.rstrip.length}) is less than #{width}\n\n"
        wrapped.last << word
      # Else, if we're less than minimum width
      elsif wrapped.last.length < min
        #puts "- new length #{wrapped.last.length + word.rstrip.length} (#{wrapped.last.length} + #{word.rstrip.length}) would be more than #{width}"
        #puts "- current length #{wrapped.last.length} is less than #{min}\n\n"
        bits = word.split_at(width - wrapped.last.length)
        wrapped.last << bits.shift
        bits.join.split_at(width)
        bits.each {|bit| wrapped << bit}
      # Else if neither can fit on current line, nor is line short enough; and
      # the word is short enough to fit on the new line
      elsif word.chomp.length < width
        #puts "- new length #{wrapped.last.length + word.rstrip.length} (#{wrapped.last.length} + #{word.rstrip.length}) would be more than #{width}"
        #puts "- current length #{wrapped.last.length} is more than #{min}"
        #puts "- word's length #{word.chomp.length} is less than #{width}\n\n"
        wrapped << word
      # If it can't fit on the current line, and it can't fit wholly on a line
      # by it's own
      else
        #puts "- new length #{wrapped.last.length + word.rstrip.length} (#{wrapped.last.length} + #{word.rstrip.length}) would be more than #{width}"
        #puts "- current length #{wrapped.last.length} is more than #{min}"
        #puts "- word's length #{word.chomp.length} is more than #{width}"
        bits = word.split_at(width)
        bits.each {|bit| wrapped << bit}
      end
      
      wrapped
    end.join("\n")
  end
  
end