($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', '..', '..', 'lib' ))).uniq!
require 'rat/ncurses/window_wrapper'
require 'rat/input_window'

# This spec doesn't actually work - it wants to use Ncurses, yet we can't
# actually utilize that, or even mock the functionality, without initializing
# it (and thus eating the terminal window in which we are assumably running
# specs). Ah well, at least they look good d-:

describe Rat::Input do
  
  describe "#back" do
    before(:all) do
      # Ncurses = mock(::Ncurses)
    end
    before(:each) do
      @input = Rat::Input.new
    end
    
    it "should return the previous item in the scrollback" do
      Ncurses.should_recieve(:COLS).and_return 50
      @input.scrollback = ["foo", "bar", "gaz", "omg", "wtf", "lol"]
      @input.index = 4
      @input.back
      @input.index.should == 3
      @input.buffer.should == "omg"
    end
  end
  
end