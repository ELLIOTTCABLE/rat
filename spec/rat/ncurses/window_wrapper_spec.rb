require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/ncurses_mock'
require 'rat/ncurses/window_wrapper'

describe Ncurses::WindowWrapper do
  before :each do
    @wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
  end
  
  describe "#initialize" do
    before :each do
      @window = Spec::Mocks::Mock.new('a window', :null_object => true)
      NcursesMock.window_mock = @window
      @wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
    end
    
    it "should accept dimensions when created" do
      @wrapper.height.should == 40
      @wrapper.width.should == 80
      @wrapper.top.should == 0
      @wrapper.left.should == 0
    end
  
    it "should refresh the window after being created" do
      @window.should_receive(:refresh).once
      Ncurses::WindowWrapper.new(40,80,0,0)
    end
  end
  
  describe "#refresh" do
    it "should refresh the window" do
      @wrapper.window.should_receive(:refresh).once
      @wrapper.refresh
    end
  end
  
  describe "#print" do
    it "should print a string" do
      string = 'A test string.'
      @wrapper.window.should_receive(:printw).with("%s", string)
      
      @wrapper.print string
    end
    
    it "should be capable of applying String#indent while printing a string" do
      string = 'A test string.'
      expected = '  A test string.'
      @wrapper.window.should_receive(:printw).with("%s", expected)
      
      @wrapper.print string, 2
    end
    
    it "should apply String#wrap while printing a string" do
      string =
        'A rather annoyingly long, and overly verbose testing string of some sort, at least I think so, anyway.'
      expected =
        "A rather annoyingly long, and overly verbose testing string of some sort, at \nleast I think so, anyway."
      @wrapper.window.should_receive(:printw).with("%s", expected)
      
      @wrapper.print string
    end
    
    it "should be capable of applying String#indent and String#wrap while printing a string" do
      string =
        'A rather annoyingly long, and overly verbose testing string of some sort, at least I think so, anyway.'
      expected =
        "  A rather annoyingly long, and overly verbose testing string of some sort, at \n  least I think so, anyway."
      @wrapper.window.should_receive(:printw).with("%s", expected)
      
      @wrapper.print string, 2
    end
  end
  
  describe "#puts" do
    it "should print a string with an extra newline" do
      string = 'A test string.'
      expected = "A test string.\n"
      @wrapper.window.should_receive(:printw).with("%s", expected)
      
      @wrapper.puts string
    end
    
    it "should refresh after printing" do
      string = 'A test string.'
      @wrapper.window.should_receive(:refresh)
      @wrapper.puts string
    end
  end
  
  describe "#terminate" do
    it "should destroy the window instance" do
      @wrapper.window.should_receive(:destroyed?).and_return(false)
      @wrapper.window.should_receive(:delwin)
      @wrapper.terminate
    end
  end
  
  describe "#recreate" do
    it "should recreate the window object" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(NcursesMock.window_mock)
      
      @wrapper.recreate
    end
    
    it "should terminate any existing window object" do
      @wrapper.should_receive(:terminate)
      
      @wrapper.recreate
    end
    
    it "should set the new window to keypad" do
      NcursesMock.window_mock.should_receive(:keypad)
      @wrapper.recreate
    end
    
    it "should refresh the new window" do
      NcursesMock.window_mock.should_receive(:refresh)
      @wrapper.recreate
    end
    
    it "should accept dimension options" do
      @wrapper.recreate(
        :height => 10,
        :width => 72,
        :top => 1,
        :left => 1
      )
      @wrapper.height.should == 10
      @wrapper.width.should == 72
      @wrapper.top.should == 1
      @wrapper.left.should == 1
    end
  end
  
  describe "#clear" do
    it "should recreate the window" do
      @wrapper.should_receive(:recreate)
      @wrapper.clear
    end
    
    it "should be capable of pushing in existing content" do
      content = "These are some testing strings.\nUse them with care!"
      @wrapper.window.should_receive(:printw).with("%s", content)
      @wrapper.clear(content)
    end
  end
end