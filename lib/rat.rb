require 'ncurses'
require 'xmpp4r'
require 'xmpp4r/roster'

require 'rat/core_ext/rspec'
require 'rat/command'
require 'rat/ncurses/window_wrapper'
require 'rat/window'
require 'rat/input'

module Rat
  Version = -1
  
  # The primary method. Initiates the application loop, and takes over the
  # terminal.
  def self.start
    # First, some Ncurses initialization
    Window::initialize
    
    # Next, we need a few windows.
    Rat::Input.new # Rat::Input.instance
    Rat::Window.new # Rat::Window.active (for now)
    
  end
  
end