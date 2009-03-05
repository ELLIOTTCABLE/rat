require File.dirname(__FILE__) + '/../../spec_helper'
require 'rat/core_ext/string'

describe String do
  describe "#constantize" do
    it "should constantize a simple word" do
      "test".constantize.should == "Test"
    end
    
    it "should constantize a snake_case word" do
      "snake_case".constantize.should == "SnakeCase"
    end
    
    it "should constantize a simple string" do
      "a simple string".constantize.should == "ASimpleString"
    end
  end
  
  describe "#/" do
    it "should concatenate another string onto this string with File::SEPARATOR" do
      ("abc" / "def").should == "abc#{File::SEPARATOR}def"
    end
  end
  
  describe "#length" do
    it "should be UTF-8 safe" do
      "‚ñ≤‚ñº‚ñ∂‚óÄ".length.should == 4
      "‚ñÅ‚ñÇ‚ñÉ‚ñÑ‚ñÖ‚ñÜ‚ñá‚ñà".length.should == 8
    end
    
    it "should be UTF-16 safe" do
      pending("unsure how to manage this - most editors won't even print these right")
      "Ì†¥Ì¥¢Ì†¥Ì¥û".length.should == 1
    end
  end
  
  describe "#fixed_split" do
    it "should work correctly when the last character is the same as the seperator" do
      '.a.b.c.'.fixed_split('.').should == ['','a','b','c','']
    end
  end
  
  describe "#split_at" do
    it "should split a string into groups at a given length" do
      'abcdefghijkl'.split_at(3).should == ['abc','def','ghi','jkl']
    end
  end
  
  describe '#indent' do
    it "should indent a single-line string" do
      string = 'abcdef'
      indented = string.indent('  ')
      indented.should == '  abcdef'
    end
  
    it "should indent a multi-line string using another string" do
      string = "abcdef\nghijkl"
      indented = string.indent('- ')
      indented.should == "- abcdef\n- ghijkl"
    end
    
    it "should indent a multi-line string using a width" do
      string = "abcdef\nghijkl"
      indented = string.indent(2)
      indented.should == "  abcdef\n  ghijkl"
    end
  
    it "should preserve inline whitespace" do
      string = "begin\n  puts 'whee!'\nend"
      indented = string.indent('  ')
      indented.should == "  begin\n    puts 'whee!'\n  end"
    end
    
    it "should preserve prefixed whitespace" do
      string = "\nI am low"
      indented = string.indent('  ')
      indented.should == "  \n  I am low"
    end
    
    it "should preserve postfixed whitespace" do
      string = "I am high\n"
      indented = string.indent('  ')
      indented.should == "  I am high\n  "
    end
    
    it "should raise if incorrectly duck punched" do
      lambda { "a string".indent(2..4) }.should raise_error ArgumentError,
        "2..4 is neither string-ish nor numeric-ish"
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
    
    it "should correctly handle line returns" do
      string = "\n  \n  This is a string\n  "
      wrapped = string.wrap(10)
      wrapped.should == "\n  \n  This is \na string\n  "
    end
  end
end
