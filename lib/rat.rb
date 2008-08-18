require 'ncurses'

require 'rat/core_ext'
require 'rat/command'
require 'rat/protocol'
require 'rat/protocols'
require 'rat/ncurses'
# require 'rat/bar'
require 'rat/window'
require 'rat/input'

class Rat::Bar
  def self.height
    1
  end
end

module Rat
  VERSION = -1
  
  # The primary method. Initiates the application loop, and takes over the
  # terminal.
  def self.start
    # First, protocol initialization
    # Protocol::Protocols.each {|protocol| protocol::initialize }
    
    # Second, some Ncurses initialization
    Window::initialize
    rodent = Ncurses::WindowWrapper.new 1, 26, (Ncurses.LINES * 0.25).to_i, (Ncurses.COLS / 2) - 13
    %w"o/ o\\ o/ o\\ o/".each {|frame| rodent.clear frame + ' '; sleep 0.5 }
    rodent.clear " (-: "
    sleep 1
    rodent.clear " (-: welcome to rat :-) "
    sleep 2
    
    # Next, we need a few windows.
    Input.new
    window = Window.new :none, :main
    
    rodent.terminate
    forever do
      Rat::Input.process ::Ncurses.getch
    end
  end
  
  Command.new(:exit) do
    rodent = Ncurses::WindowWrapper.new 1, 26, (Ncurses.LINES * 0.25).to_i, (Ncurses.COLS / 2) - 13
    %w"o/ o\\ o/ o\\ o/".each {|frame| rodent.clear frame + ' '; sleep 0.5 }
    rodent.clear " :-( bye bye )-: "
    sleep 1
    # Protocol::Protocols.each {|protocol| protocol::terminate }/
    exit
  end
end
