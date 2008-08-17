require File.dirname(__FILE__) + '/../../spec_helper'
require 'ncurses'
require 'rat/ncurses/window_wrapper'

describe Ncurses::WindowWrapper do
  before :all do
    silently do
      Ncurses::ROWS = 40
      Ncurses::COLS = 80
    end
  end
  before :each do
    @window = mock("a window", :null_object => true)
  end
  
  describe "#initialize" do
    it "should accept dimensions when created" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
    
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      wrapper.height.should == 40
      wrapper.width.should == 80
      wrapper.top.should == 0
      wrapper.left.should == 0
    end
  
    it "should refresh the window after being created" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
    
      @window.should_receive(:refresh).once
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
    end
  end
  
  describe "#refresh" do
    it "should refresh the window" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      @window.should_receive(:refresh).once
      wrapper.refresh
    end
  end
  
  describe "#print" do
    it "should print a string" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string = 'A test string.'
      @window.should_receive(:printw).with("%s", string)
      
      wrapper.print string
    end
    
    it "should be capable of applying String#indent while printing a string" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string = 'A test string.'
      expected = '  A test string.'
      @window.should_receive(:printw).with("%s", expected)
      
      wrapper.print string, 2
    end
    
    it "should apply String#wrap while printing a string" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string =
        'A rather annoyingly long, and overly verbose testing string of some sort, at least I think so, anyway.'
      expected =
        "A rather annoyingly long, and overly verbose testing string of some sort, at \nleast I think so, anyway."
      @window.should_receive(:printw).with("%s", expected)
      
      wrapper.print string
    end
    
    it "should be capable of applying String#indent and String#wrap while printing a string" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string =
        'A rather annoyingly long, and overly verbose testing string of some sort, at least I think so, anyway.'
      expected =
        "  A rather annoyingly long, and overly verbose testing string of some sort, at \n  least I think so, anyway."
      @window.should_receive(:printw).with("%s", expected)
      
      wrapper.print string, 2
    end
  end
  
  describe "#puts" do
    it "should print a string with an extra newline" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string = 'A test string.'
      expected = "A test string.\n"
      @window.should_receive(:printw).with("%s", expected)
      
      wrapper.puts string
    end
    
    it "should refresh after printing" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      string = 'A test string.'
      @window.should_receive(:refresh)
      wrapper.puts string
    end
  end
  
  describe "#terminate" do
    it "should destroy the window instance" do
      Ncurses.should_receive(:newwin).with(40,80,0,0).and_return(@window)
      wrapper = Ncurses::WindowWrapper.new(40,80,0,0)
      
      @window.should_receive(:destroyed?).and_return(false)
      @window.should_receive(:delwin)
      wrapper.terminate
    end
  end
  
end