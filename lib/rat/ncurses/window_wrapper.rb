require 'ncurses'

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
    
    def print string, indent = 0
      first = true # I WANT ARRAY#MAP_WITH_INDEX!
      string = string.gsub(/.{1,#{@width - 1 - indent}}/m) do |sect|
        sect = first ? sect : "\n" + (' ' * indent) + sect
        first = false
        sect
      end
      @window.printw("%s", string)
    end
    
    def close
      @window.delwin unless @window.destroyed?
    end
    
    # Re-creates the window itself, thus clearing all content. Optionally, can
    # subsequently fill the new window with new content.
    def clear(content = nil)
      close if @window
      @window = Ncurses.newwin(@height, @width, @top, @left)
      @window.keypad true
      self.print content if content
      @window.refresh
    end
    
  end
end