require 'rat/core_ext/rspec'
require 'rat/command'
require 'rat/ncurses/window_wrapper'
require 'rat/window'
require 'rat/input_window'

module Rat
  Version = -1
  
  # The primary method. Initiates the application loop, and takes over the
  # terminal.
  def start
    # First, some Ncurses initialization
    Window::initialize
    
    # Next, we need an input area.
    Rat::Input.new(1, Ncurses.COLS, Ncurses.LINES - 1, 0)
    
    # Finally, an output window!
    # Rat::Window.new(Ncurses.LINES - 1, Ncurses.COLS, 0, 0) # How do I track multiples, or access this later?
  end
  
end