module Rat
  class Command
    
    @@commands = {}
    def self.commands
      @@commands
    end
    
    # Returns the +Command+ with the given name.
    def self.[] name
      if @@commands.include? name.to_sym
        @@commands[name.to_sym]
      else
        lambda { Rat::Window.active.puts "Unknown command '#{name}'" }
      end
    end
    
    @@hotkeys = {}
    def self.hotkeys
      @@hotkeys
    end
    
    def self.hotkey key
      key = @@hotkeys[key]
      raise ArgumentError, 'No such hotkey' unless key
      
      case key
      when Proc
        key.call
      else
        @@commands[key].call
      end
    end
    
    attr_reader :name
    attr_accessor :block
    
    def initialize name, &block
      @name = name.to_sym
      @block = block
      @@commands[name.to_sym] = self
    end
    
    # Runs self with arguments
    def call *args
      case @block.arity
      when 1..Infinity   # Normal arguments
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for #{@block.arity.to_s})" unless
          args.size == @block.arity
        @block[*args]
        
      when 0        # No arguments with bars {|| }
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for none)" unless
          args.size == 0
        @block.call
        
      when -Infinity..-2 # x-1 arguments plus a splat argument
        raise ArgumentError,
          "Wrong number of arguments (#{args.size.to_s} for #{(-@block.arity - 1).to_s}+)" unless
          args.size >= (-@block.arity) - 1
        @block[*args]
      
      when -1       # Arguments handeled on-board {|*args| }, or ignore all args {}
        # Not going to raise any errors, this is the wildcard for script
        # kiddies
        @block[*args]
        
      end
    end
    
    alias_method :[], :call
  end
end

Rat::Command.new(:commands) { Rat::Window.active << "Commands: " + Rat::Command.commands.map {|n,c|n.to_s}.sort.join(', ') }

# TODO: Rework this. I really don't like what it prints, we need an inbuilt
# documentation/help system for commands and hotkeys. Oh, and an array to
# match numeric characters with english phrases - nobody knows what ^(260) is.
Rat::Command.new(:hotkeys) do
  Rat::Window.active << "Hotkeys: " + Rat::Command.hotkeys.map do |key, command|
    char = key.chr rescue "(#{key.to_s})"
    comm = case command
    when Symbol, String
      '/' + command.to_s
    when Proc
      '(Script)'
    end
    "^#{char} => #{comm}"
  end.sort.join(', ')
end