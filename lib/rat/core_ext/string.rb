class String
  
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
  
end

# ---- Indentation ---- #
# [See the specs at the bottom for a more verbose and specific description]
# A) Indent every line except the first (assume something as wide as INDENT
#     has already been printed) to INDENT spaces in.
# B) Visible characters (non-whitespace) must never exceed WIDTH
#   1) Wrap automatically at word boundary, if there is a boundary within
#       MIN_WIDTH
#     i) Deal properly with quotations, punctuation, etcetra - don't place a
#         word on a line, and then a period or quote alone on the line after
#         that. Same applies for punctuation/quotations before a line.
#   2) Wrap automatically at WIDTH, if there is no boundary within MIN_WIDTH
# C) Preserve existing whitespace (but do not include whitespace at EOL for B)

class String
  def indent spaces
    if spaces.respond_to? :to_s # duck,
      self.split("\n").map {|s| [spaces, s].join }.join("\n")
    elsif spaces.respond_to? :to_i # duck,
      self.split("\n").map {|s| [(' ' * spaces), s].join }.join("\n")
    else # goose!
      raise ArgumentError, "#{spaces} is neither string-ish nor numeric-ish"
    end
  end
  
  def wrap width
    raise ArgumentError, "#{width} is not numeric-ish" unless width.respond_to? :to_i
    
  end
end

if defined? Spec
  describe String do
    describe '#indent' do
      it "should indent a single-line string" do
        string = 'abcdef'
        indented = string.indent('  ')
        indented.should == '  abcdef'
      end
    
      it "should indent a multi-line string" do
        string = "abcdef\nghijkl"
        indented = string.indent('  ')
        indented.should == "  abcdef\n  ghijkl"
      end
    
      it "should preserve whitespace" do
        string = "begin\n  puts 'whee!'\nend"
        indented = string.indent('  ')
        indented.should == "  begin\n    puts 'whee!'\n  end"
      end
    end
  
    describe '#wrap' do
      it "should wrap a long, continuous string at `width`" do
        string = '0123456789' * 3
        wrapped = string.wrap(10)
        wrapped.should == "0123456789\n0123456789\n0123456789"
      end
    
      it "should wrap a sentence at the last word boundary before `width`" do
        string = 'The quick blue merle Tucker jumped over the mean black and white Jazz.'
        wrapped = string.wrap(30)
        wrapped.should == "The quick blue merle Tucker \njumped over the mean black and \nwhite Jazz."
      end
    end
  end
end