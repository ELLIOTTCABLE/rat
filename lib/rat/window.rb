module Rat
  class Window < Ncurses::WindowWrapper
    @@windows = []
    # Returns a list of windows
    def self.windows
      @@windows
    end
    
    # Not to be confused with +Ncurses::WindowWrapper#initialize+ or
    # +Window#initialize+, this sets up Ncurses for use.
    def self.initialize
      at_exit { Ncurses.endwin }
      
      Ncurses.initscr
      Ncurses.cbreak
      Ncurses.keypad(Ncurses.stdscr, true)
      Ncurses.noecho
      Ncurses.refresh
      Ncurses.start_color if Ncurses.has_colors?
      
      @@initialized = true
    end
    
    # Predicate, determines if the windowing environment has been initialized
    def initialized?
      @@initialized
    end
    
    @@active = nil
    # Returns the active window, if any
    def self.active
      @@active
    end
    
    def self.activate window
      window.activate
    end
    
    attr_reader :scrollback
    attr_accessor :name
    
    def initialize name = ""
      raise 'You must initialize the environment first!' unless @@initialized
      @scrollback = []
      @name = name
      
      # height, width, top, left - defaults to all but one line tall
      super Ncurses.LINES - 2, Ncurses.COLS, 0, 0
      
      @@windows << self
      
      activate
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
      clear
      @window.scrollok(true)
      @scrollback.each do |time, line|
        self.print("[#{timestamp time}] #{line}\n") # +#puts+ would refresh
      end
      refresh
    end
    
  end
end