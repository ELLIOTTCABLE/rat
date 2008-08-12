require File.dirname(__FILE__) + '/../../spec_helper'
require 'rat/core_ext/string'

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
      string =  'The quick blue merle Tucker ' + # Jumped would make this 34 characters, so it should wrap
                'jumped over the mean black and ' +
                'white Jazz.'
      wrapped = string.wrap(30)
      wrapped.should == "The quick blue merle Tucker \njumped over the mean black and \nwhite Jazz."
    end
  end
end