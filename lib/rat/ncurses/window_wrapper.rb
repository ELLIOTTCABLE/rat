module Ncurses
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
    
    def puts string, indent = 0, newline = "\n"
      self.print(string + newline, indent) if string
      refresh
    end
    
    # Implement this correctly for manual newlines and lines > window width
    def print string, indent = 0
      first = true
      string = string.gsub(/[^\n]{1,#{@width - 1 - indent}}/m) do |sect|
        sect = first ? sect : "\n" + sect
        first = false
        sect
      end
      string = string.gsub(/.*\n?/) do |line|
        sect = first ? sect : "\n" + (' ' * indent) + line
        sect
      end
      
      
      @window.printw("%s", string)
    end
    
    def terminate
      @window.delwin unless @window.destroyed?
    end
    
    def recreate opts = {}
      terminate if @window
      
      @window = Ncurses.newwin(
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
      self.print content if content
      refresh
    end
    
  end
end