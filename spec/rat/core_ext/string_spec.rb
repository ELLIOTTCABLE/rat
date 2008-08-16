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
    it "should split a string as close to the boundary as possible" do
      string = "This is a string"
      wrapped = string.wrap(10)
      wrapped.should == "This is a \nstring"
    end
    
    it "should split a word if no natural split is available" do
      string = "Pneumonoultramicroscopicsilicovolcanokoniosis"
      wrapped = string.wrap(15)
      wrapped.should == "Pneumonoultrami\ncroscopicsilico\nvolcanokoniosis"
    end
    
    it "should prefer to split a word if the nearest natural split is too far from the boundary" do
      string = "This was pneumonoultramicroscopicsilicovolcanokoniosis"
      wrapped = string.wrap(15)
      wrapped.should == "This was pneumo\nnoultramicrosco\npicsilicovolcan\nokoniosis"
    end
  end
end