module Rat
  class Window < Ncurses::WindowWrapper
    
    # Not to be confused with +Ncurses::WindowWrapper#initialize+ or
    # +Window#initialize+, this sets up Ncurses for use.
    def self.initialize
      Ncurses.initscr
      Ncurses.cbreak
      Ncurses.keypad(Ncurses.stdscr, true)
      Ncurses.noecho
      Ncurses.refresh
      Ncurses.start_color if Ncurses.has_colors?
    end
    
    @@active = nil
    # Returns the active window, if any
    def self.active
      @@active
    end
    
    def self.activate window
      window.activate
    end
    
    def active?
      @@active == self
    end
    
    def activate
      @@active.close if @@active
      @@active = self
      reset
    end
    
    attr_reader :scrollback
    
    def initialize
      @scrollback = []
      
      at_exit do
        Ncurses.endwin
      end
      
      # height, width, top, left - defaults to all but one line tall
      super Ncurses.LINES - 2, Ncurses.COLS, 0, 0
      
      activate unless @@active
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