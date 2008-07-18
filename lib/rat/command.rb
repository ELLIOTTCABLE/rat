module Rat
  class Command
    
    ImpromptuClasses = Rat, Rat::Window, Rat::InputWindow
    
    # Returns the +Command+ with the given name - also creates impromptu
    # +Command+ objects (without arguments, however) for methods on +Rat+,
    # +Window+, and +InputWindow+ (in that order of priority).
    def self.[] name
      if @@commands.include? name
        return @@commands[name]
      else
        ImpromptuClasses.each do |klass|
          
          if klass.respond_to? name
            return Rat::Command.new(name) { klass.send(name) }
          end
          
        end
      end
      
      nil
    end
    
    attr_reader :name, :impromptu
    attr_accessor :block
    
    def initialize name, impromptu = false, &block
      raise ArgumentError, 'Name must be a symbol' unless name = name.to_sym rescue nil
      @name = name
      @block = block
      @impromptu = impromptu
      @@commands[name] = self
    end
    
    # Runs the command with arguments
    def [] *args
      raise ArgumentError unless @block.arity == args.size
      
      @block[*args]
    end
    
  end
end