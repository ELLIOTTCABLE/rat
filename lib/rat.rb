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
    
    # Next, we need a few windows.
    Input.new
    window = Window.new :none, :main
    
    forever do
      Rat::Input.process ::Ncurses.getch
    end
  end
  
  Command.new(:exit) do
    # Protocol::Protocols.each {|protocol| protocol::terminate }
    exit
  end
end
