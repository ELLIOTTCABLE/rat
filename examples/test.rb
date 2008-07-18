($:.unshift File.expand_path(File.join( File.dirname(__FILE__), '..', 'lib' ))).uniq!

begin
  require 'rubygems'
  require 'ncurses'
  require 'rat'

  Rat.start

  @input = Rat::Input.instance
  @output = Rat::Window.active

  @status = Ncurses::WindowWrapper.new 1, 10, Ncurses.LINES - 1, Ncurses.COLS - 10
  @debug = Ncurses::WindowWrapper.new 1, Ncurses.COLS, Ncurses.LINES - 2, 0
  @debug.refresh

  @debug.print "#{@input.buffer.inspect} (#{@input.index}/#{@input.scrollback.size - 1})\
   #{@input.scrollback.inspect}"
  
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
      @status.clear
      char = input.chr rescue '??'
      @status.print "#{input}:#{char}"
      @status.refresh
      
      @debug.clear
      @debug.print "#{@input.buffer.inspect}\
 (#{@input.index}/#{@input.scrollback.size - 1}) #{@input.scrollback.inspect}"
      @debug.refresh
    end
    
  end
  
rescue Interrupt
  exit
rescue StandardError => e
  raise e
end