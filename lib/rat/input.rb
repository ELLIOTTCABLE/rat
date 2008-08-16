module Rat
  class Input < ::Ncurses::WindowWrapper
    
    @@instance = nil
    def self.instance
      @@instance
    end
    
    def self.process key
      case key
      when ::Ncurses::KEY_RESIZE # SIGWINCH - window resized
        # TODO: Implement this
        
      when 27 # Escape          ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        Command.hotkey ::Ncurses.getch
        
      when 127, 263 # Backspace      ---- ---- ---- ---- ---- ---- ---- ---- #
        @@instance.buffer = @@instance.buffer[0..-2] # Strip the last character
        @@instance.reset
        
      when 259 # Up arrow       ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        @@instance.back
        
      when 258 # Down arrow     ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        @@instance.forward
        
      when 260 # Left arrow     ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        # TODO: Implement this
        
      when 261 # Right arrow    ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        # TODO: Implement this
        
      when ?\n # Line return    ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        if @@instance.buffer =~ %r%^/%
          command, arguments = @@instance.buffer.gsub(%r%^/%, '').match(/^(\w*)(?:\s+(.*))?/)[1, 2]
          command = Command[command.to_sym]
          arguments ? command[*arguments.split(' ')] : command.call

          @@instance.cycle
        else
          Window.active.protocol << @@instance.cycle
        end
        
      else # Normal character   ---- ---- ---- ---- ---- ---- ---- ---- ---- #
        return if key == -1 # Dunno what causes these, but let's get rid of them
        char = key.chr rescue "(#{key.to_s})"
        @@instance << char
      end
    end
    
    # Not to be confused with +Window+'s +scrollback+ variable, this is
    # for typing history ala irssi.
    attr_accessor :scrollback
    attr_accessor :buffer
    attr_accessor :index
    
    # This forces InputWindow to be a psuedo-singleton class - creating a new
    # instance closes the last instance's window.
    def initialize
      @@instance.terminate if @@instance
      @@instance = self
      
      @scrollback = []
      @buffer = ""
      @index = nil
      
      # height, width, top, left - defaults to one line tall
      super 1, ::Ncurses.COLS, ::Ncurses.LINES - 1, 0
    end
    
    # Concatenates a string to the end of the current buffer.
    def << string
      @index = nil
      @buffer << string
      self.puts string
      string
    end
    
    # Adds the buffer to the scrollback, and empties it. Returnes said buffer,
    # assumably to print it to an output.
    def cycle
      @index = nil
      @scrollback << @buffer unless @buffer.empty?
      @buffer = ""
      reset
      @scrollback.last
    end
    
    def back
      # There's not much I can do if you don't have a history!
      return @buffer if @scrollback.empty?
      
      # If we don't have an index, we're at the end of the buffer (as in, most
      # of the time, assumably).
      if not defined?(@index) or @index.nil?
        @index = @scrollback.size
      end
      @index -= 1 unless @index.zero?
      @buffer = @scrollback[@index]
      
      reset
    end
    
    def forward
      # If we don't have an index, we're at the end of the buffer (as in, most
      # of the time, assumably).
      if not defined?(@index) or @index.nil?
        @index = @scrollback.size - 1
      end
      
      @index += 1 if @index < @scrollback.size
      @buffer = @index == @scrollback.size ? "" : @scrollback[@index]
      
      reset
    end
    
    # Clears the input box, filling it with whatever is in the buffer
    def reset
      clear
      self.puts @buffer
      self
    end
    
  end
end