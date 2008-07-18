($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', 'lib' ))).uniq!

begin
  require 'rubygems'
  require 'ncurses'
  require 'rat'

  Rat.start

  @input = Rat::Input.instance
  @output = Rat::Window.active

  @statusbar = Ncurses::WindowWrapper.new 1, Ncurses.COLS - 10, Ncurses.LINES - 2, 0
  @debug = Ncurses::WindowWrapper.new 1, 10, Ncurses.LINES - 2, Ncurses.COLS - 10
  
  while true
    input = Ncurses.getch
    
    case input
    when 127, 263 # Backspace    ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.buffer = @input.buffer[0..-2] # Strip the last character
      @input.reset

    when 27 # Escape          ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      index = Rat::Window.windows.index Rat::Window.active
      index += 1
      if Rat::Window.windows.size == index
        index = 0
      end
      window = Rat::Window.windows[index]
      window.activate
      
    when 259 # Up arrow       ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.back
      
    when 258 # Down arrow     ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input.forward
    
    when 260 # Left arrow     ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      # TODO: Implement this
      
    when 261 # Right arrow    ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      # TODO: Implement this
      
    when ?\n # Line return    ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      if @input.buffer =~ %r%^/%
        command, arguments = @input.buffer.gsub(%r%^/%, '').match(/^(\w*)(?: (.*)$)?/)[1, 2]
        command = Rat::Command[command.to_sym]
        arguments ? command[*arguments.split(',')] : command[]
        
        @input.cycle
      else
        Rat::Window.active << @input.cycle
      end
      
    else # Normal character   ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @input << input.chr
    end
    
    if true # Debug!          ---- ---- ---- ---- ---- ---- ---- ---- ---- #
      @debug.clear
      char = input.chr rescue '??'
      @debug.print "#{input}:#{char}"
      @debug.refresh
      
      @statusbar.clear
      @statusbar.print "#{@input.buffer.inspect}\
 (#{@input.index}/#{@input.scrollback.size - 1}) #{@input.scrollback.inspect}"
      @statusbar.refresh
    end
    
  end
  
rescue Interrupt
  exit
rescue StandardError => e
  raise e
end