module Rat
  class Bar < Ncurses::WindowWrapper
    @@bars = []
    def self.bars
      @@bars
    end
    
    # Returns the total number of lines taken by all active bars.
    def self.height
      Bar::hash.size
    end
    
    # Refreshes the whole statusbar, re-sorting the the bars and refreshing
    # them in turn.
    def self.refresh
      Bar::hash Ncurses::COLS
      
      @@bars.each {|b| b.refresh }
    end
    
    # Hashes all currently kown bars, returning a hash of line numbers and
    # bars on that line, sorting the bars as defined by #<=>, and splitting
    # the bars into groups of as many as can fit within max_width.
    def self.hash max_width
      @@bars.sort!
      @@bars.each {|b| b.reindex! }
      
      total = 0
      @@bars.group_by do |bar|
        next unless bar.active?
        total += bar.width
        (total - 1) / max_width
      end
    end
    
    # The 'priority' of a bar, forces it towards the front (and top) of the
    # bars (if posititive) or the other way (if negative). Defaults to 0.
    attr_accessor :priority
    def priority= priority
      @priority = priority
      Bar::resort
    end
    
    # The index of a bar in the whole list.
    attr_accessor :index
    def index= index
      @index = index
      Bar::resort
    end
    # Re-sets the +index+ to the bars actual index in the +bars+ array.
    def reindex!
      @index = @@bars.index self
    end
    
    # The alloted space for the bar.
    attr_accessor :width
    
    # Whether or not the bar is 'active'. Inactive bars will not be displayed.
    attr_accessor :active
    
    def initialize name, opts = {}
      @priority = opts[:priority] || 0
      @width = opts[:width] || 10
      @width = opts[:active] || true
      
      yield self if block_given?
      
      @@bars << self
      Bar::refresh
    end
    
    # Compares two +Bar+s, selecting either the one with the higher priority,
    # or possibly the higher index (if neither has a priority).
    def <=> other
      if self.priority == 0 && other.priority == 0
        self.index <=> other.index
      else
        self.priority <=> other.priority
      end
    end
  end
end