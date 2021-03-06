module Rat
  # A +Rat+ '+Window+' is not a positioned window on the screen (like its
  # parent +Ncurses::WINDOW+) - it's a content window in which one can chat
  # with people or whatever. A list of 'open' windows is maintained, and the
  # objects are preserved - but the actual +Ncurses::WINDOW+ is destroyed and
  # only re-created when it's active.
  class Window < ::Ncurses::WindowWrapper
    @@windows = []
    # Returns a list of windows
    def self.windows
      @@windows
    end
    
    # Not to be confused with +Ncurses::WindowWrapper#initialize+ or
    # +Window#initialize+, this sets up Ncurses for use.
    def self.initialize
      at_exit { ::Ncurses.endwin }
      
      ::Ncurses.initscr
      # ::Ncurses.cbreak
      # ::Ncurses.keypad(::Ncurses.stdscr, true)
      ::Ncurses.nocbreak
      ::Ncurses.noecho
      ::Ncurses.refresh
      ::Ncurses.start_color if ::Ncurses.has_colors?
      
      @@initialized = true
    end
    
    # Predicate, determines if the windowing environment has been initialized
    def self.initialized?
      @@initialized
    end
    
    @@active = nil
    # Returns the active window, if any
    def self.active
      @@active
    end
    
    # Returns the number of 'available' lines in the terminal window. The
    # total terminal lines minus the status bars and input window.
    def self.available_height
      ::Ncurses.LINES - Bar::height - 1
    end
    
    attr_reader :scrollback
    attr_accessor :target
    attr_accessor :protocol
    
    def initialize protocol = nil, target = nil
      raise 'You must initialize the environment first!' unless Window::initialized?
      @scrollback = []
      @target = target
      
      # height, width, top, left - defaults to all but one line tall
      super Window::available_height, ::Ncurses.COLS, 0, 0
      
      @@windows << self
      
      @protocol = case protocol
      when Symbol, String, nil
        protocol = protocol.nil? ? :none : protocol.to_sym
        protocol = protocol.to_s.constantize
        protocol = Protocol.const_get protocol
        protocol.new self, @target
      else
        raise ArgumentError, 'Only accepts a symbol or an instance of a protocol' unless
          protocol.class.ancestors.include? Protocol
        protocol
      end
      
      activate
    end
    
    def index
      Window.windows.index self
    end
    
    def active?
      @@active == self
    end
    
    def activate
      @@active.terminate if @@active
      @@active = self
      reset
    end
    
    def << string
      @scrollback << [Time.now, string]
      ts = "[#{timestamp @scrollback.last[0]}] "
      self.puts ts + string, ts.length
      self
    end
    
    def timestamp time
      time.strftime('%H:%M')
    end
    
    def puts *args
      super *args if active?
    end
    
    # Removes a window from the window list. The window and its scrollback
    # still exists, and won't fail if pushed to or still referenced somewhere.
    def close
      @@windows.remove self
      terminate
    end
    
    # Fully clears a window's content, clearing the scrollback as well.
    def clear_scrollback
      @scrollback = []
      clear
    end
    
    # Re-set a window, clearing any content and re-printing the scrollback to
    # the new window.
    def reset
      recreate :height => Window::available_height
      @window.scrollok(true)
      @scrollback.each do |time, line|
        self.print("[#{timestamp time}] #{line}\n") # +#puts+ would refresh
      end
      refresh
    end
    
  end
  
  Command.new :window do |command, *args|
    Command[['window', command].join('_')][*args]
  end

  Command.new :window_new do |*args|
    raise ArgumentError, "Wrong number of arguments (#{args.size} for two-)" unless args.size <= 2
    protocol = args[0]
    target = args[1]
    window = Window.new(protocol, target)
    window.puts args.inspect
  end

  Command.new :window_show do |num|
    window = Window.windows[num.to_i]
    window.activate if window
  end

  Command.new :window_info do ||
    w = Window.active
    w << "#{w.protocol.class.to_s} #{w.target}[#{w.index}]"
  end

  (?0..?9).each {|n| Command.hotkeys[n] = lambda { Command[:window_show][n.chr] } } # Number keys
  Command.new :window_list do ||
    windows_list = Window.windows.map do |window|
      "#{window.target}[#{window.index}]"
    end.join(' ')
    Window.active << "Windows: (target[id]) #{windows_list}"
  end

  Command.hotkeys[260] = :window_next # Right arrow key
  Command.new :window_next do ||
    index = Window.active.index
    index += 1
    index = 0 if Window.windows.size == index
    Window.windows[index].activate
  end

  Command.hotkeys[261] = :window_previous # Left arrow key
  Command.new :window_previous do ||
    index = Window.active.index
    index = Window.windows.size if 0 == index
    index -= 1
    Window.windows[index].activate
  end

  Command.new(:window_clear) {|| Window.active.clear }
  Command.new(:window_reset) {|| Window.active.reset }
end
