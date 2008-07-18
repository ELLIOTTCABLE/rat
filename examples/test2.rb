($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', 'lib' ))).uniq!

require 'rubygems'
require 'ncurses'
require 'rat'

Rat::Window.initialize

# @output = Rat::Window.new
# @input = Rat::Input.new
@debug = Ncurses::WindowWrapper.new 1, 10, Ncurses.LINES - 1, Ncurses.COLS - 10

begin
  while true
    
  end
rescue Interrupt
  Ncurses.echo
  Ncurses.endwin
  exit
end