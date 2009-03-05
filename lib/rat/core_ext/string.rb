require 'rubygems'
require 'stringray'

class String
  include StringRay
  
  # Constantizes a string, changing it from snake_case or 'space case' to
  # TitleCase, however necessary
  def constantize
    str = self
    str = str.gsub /\s/u, '_'
    str = str.gsub(/(^|_)(\w)/u) { "#{$2.capitalize}" }
  end
  
  def /(o)
    File.join(self, o.to_s)
  end
  
  def indent spaces
    if spaces.respond_to? :to_str # duck,
      self.fixed_split("\n").map {|s| [spaces, s].join }.join("\n")
    elsif spaces.respond_to? :to_i # duck,
      self.fixed_split("\n").map {|s| [(' ' * spaces), s].join }.join("\n")
    else # goose!
      raise ArgumentError, "#{spaces} is neither string-ish nor numeric-ish"
    end
  end
  
  # Ruby 1.8's #length doesn't like multibyte Unicode. Thanks Mikael Høilund!
  def length
    self.scan(/./um).size
  end if RUBY_VERSION <= "1.9"
  
  # Ruby 1.8's #split method doesn't like for the last character to be an
  # instance of the seperator
  def fixed_split *args
    arr = self.split *args
    arr << "" if self != '' and self[-1].chr == args.first
    arr
  end
  
  # Simply returns an array of string pieces split into groups of +length+
  # characters.
  def split_at length
    self.scan /.{1,#{length}}/u
  end
  
  # Wraps a string, *intelligently*
  def wrap width, min = nil
    raise ArgumentError, "#{width} is not numeric-ish" unless width.respond_to? :to_i
    min ||= (width.to_i * 0.75).to_i # Default to about a third of the full width
    raise ArgumentError, "#{min} is not numeric-ish" unless min.respond_to? :to_i
    
    self.fixed_split("\n").map do |line|
      wrapped = [""]
      line.enumerate do |word|
        if wrapped.last.length + word.rstrip.length <= width
          wrapped.last << word
        
        elsif wrapped.last.length < min
          wrapped.last << word.slice!(0, width - wrapped.last.length)
          bits = word.split_at(width)
          bits.each {|bit| wrapped << bit}
        
        elsif word.chomp.length < width
          wrapped << word
        
        else
          bits = word.split_at(width)
          bits.each {|bit| wrapped << bit}
        end
      end
      wrapped.join("\n")
    end.join("\n")
  end
  
end
