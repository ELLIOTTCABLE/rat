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
    
    attr_reader :name
    attr_accessor :block
    
    def initialize name, &block
      @name = name
      @block = block
      @@commands[name] = self
    end
    
    # Runs the command with arguments
    def [] *args
      raise ArgumentError,
        "Wrong number of arguments (#{args.size.to_s} for #{@block.arity.to_s})" unless
        @block.arity < args.size
      
      @block[*args]
    end
  end
end

Rat::Command.new(:exit) { exit }
Rat::Command.new(:clear) { Rat::Window.active.clear }
Rat::Command.new(:commands) { Rat::Window.active.puts Rat::Command.commands.map {|n,c|n.to_s}.sort.join(', ') }