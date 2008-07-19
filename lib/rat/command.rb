module Rat
  class Command
    
    @@commands = {}
    def self.commands
      @@commands
    end
    
    # Returns the +Command+ with the given name.
    def self.[] name
      if @@commands.include? name
        @@commands[name]
      else
        lambda { Rat::Window.active.puts "Unknown command" }
      end
    end
    
    # TODO: Rework this to use a hash instead of a case
    def self.hotkey key
      case key
      when 260 # Left arrow
        index = Rat::Window.windows.index Rat::Window.active
        index += 1
        index = 0 if Rat::Window.windows.size == index
        Rat::Window.windows[index].activate
        
      when 261 # Right arrow
        index = Rat::Window.windows.index Rat::Window.active
        index = Rat::Window.windows.size if 0 == index
        index -= 1
        Rat::Window.windows[index].activate
        
      when 48..57 # Number keys
        window = Rat::Window.windows[key.chr.to_i]
        window.activate if window
        
      end
    end
    
    attr_reader :name
    attr_accessor :block
    
    def initialize name, &block
      @name = name
      @block = block
      @@commands[name] = self
    end
    
    # Runs the command with arguments
    def call *args
      case @block.arity
      when 1..999   # Normal arguments
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for #{@block.arity.to_s})" unless
          args.size == @block.arity
        @block[*args]
        
      when -1, 0    # No arguments no bars { }, no arguments with bars {|| }
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for none)" unless
          args.size == 0
        @block.call
        
      when -999..-2 # x-1 arguments plus a splat argument
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for #{(-@block.arity - 1).to_s}+)" unless
          args.size >= -@block.arity
        @block[*args]
      end
    end
    
    alias_method :[], :call
  end
end

Rat::Command.new(:exit) { exit }
Rat::Command.new(:clear) { Rat::Window.active.clear }
Rat::Command.new(:reset) { Rat::Window.active.reset }
Rat::Command.new(:commands) { Rat::Window.active << "Commands: " + Rat::Command.commands.map {|n,c|n.to_s}.sort.join(', ') }
Rat::Command.new :window_list do
  windows_list = Rat::Window.windows.map do |window|
    index = Rat::Window.windows.index window
    "#{window.name}[#{index}]"
  end.join(' ')
  Rat::Window.active << "Windows: (name[id]) #{windows_list}"
end

Rat::Command.new :window_new do |name|
  Rat::Window.new name
end

Rat::Command.new :window do |command, *args|
  Rat::Command[['window', command].join('_')][*args]
end