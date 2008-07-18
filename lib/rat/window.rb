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
      
      # height, width, top, left - defaults to all but one line tall
      super Ncurses.LINES - 2, Ncurses.COLS, 0, 0
      
      activate unless @@active
    end
    
    def << string
      @scrollback << string
      self.puts string
      self
    end
    
    def puts string
      super string if active?
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
      @scrollback.each do |line|
        self.print(line + "\n") # Not using +#puts+, as that will refresh each
      end
      refresh
    end
    
  end
end