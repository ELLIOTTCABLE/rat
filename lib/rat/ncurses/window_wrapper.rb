module ::Ncurses
  class WindowWrapper
    
    attr_reader :window
    attr_accessor :height, :width, :top, :left
    
    def initialize height, width, top, left
      @height, @width, @top, @left = height, width, top, left
      clear
    end
    
    def refresh
      @window.refresh
    end
    
    def print string, indent = 0
      @window.printw("%s", string.wrap(::Ncurses.COLS - indent).indent(indent))
    end
    
    def puts string, indent = 0, newline = "\n"
      self.print(string + newline, indent) if string
      refresh
    end
    
    def terminate
      @window.delwin unless @window.destroyed?
    end
    
    def recreate opts = {}
      terminate if @window
      
      @window = ::Ncurses.newwin(
        opts[:height] ? @height = opts[:height] : @height,
        opts[:width]  ? @width =  opts[:width]  : @width,
        opts[:top]    ? @top =    opts[:top]    : @top,
        opts[:left]   ? @left =   opts[:left]   : @left)
      
      @window.keypad true
      refresh
    end
    
    # Re-creates the window itself, thus clearing all content. Optionally, can
    # subsequently fill the new window with new content.
    def clear content = nil
      recreate
      if content
        self.print content
        refresh
      end
    end
    
  end
end