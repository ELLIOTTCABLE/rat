($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', 'lib' ))).uniq!

require 'rubygems'
require 'ncurses'
require 'rat'

Rat::Window.initialize

@input = Rat::Input.new
@input.scrollback = ["foo", "bar", "gaz"]
@status = Ncurses::WindowWrapper.new 1, 10, Ncurses.LINES - 1, Ncurses.COLS - 10
@debug = Ncurses::WindowWrapper.new 1, Ncurses.COLS, Ncurses.LINES - 2, 0
@debug.refresh

@output1 = Rat::Window.new
@output2 = Rat::Window.new
@output1.activate

@debug.print "#{@input.buffer.inspect} (#{@input.index}/#{@input.scrollback.size - 1})\
 #{@input.scrollback.inspect} #{@output1.scrollback.inspect} #{@output2.scrollback.inspect}"

begin
  while true
    input = Ncurses.getch
    
    case input
    when 263 # Backspace      ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.buffer = @input.buffer[0..-2] # Strip the last character
      @input.reset

    when 27 # Escape          ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @output1.active? ? @output2.activate : @output1.activate
      
    when 259 # Up arrow       ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.back
      
    when 258 # Down arrow     ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.forward
      
    when ?\n # Line return    ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      Rat::Window.active << @input.cycle
      @input.reset
      
    else # Normal character   ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input << input.chr
    end
    
    if true # Debug!          ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @status.clear
      char = input.chr rescue '??'
      @status.print "#{input}:#{char}"
      @status.refresh
      
      @debug.clear
      @debug.print "#{@input.buffer.inspect}\
 (#{@input.index}/#{@input.scrollback.size - 1}) #{@input.scrollback.inspect}\
 #{@output1.scrollback.inspect} #{@output2.scrollback.inspect}"
      @debug.refresh
    end
    
  end
rescue Interrupt
  Ncurses.endwin
  exit
rescue StandardError => e
  Ncurses.endwin
  raise e
end