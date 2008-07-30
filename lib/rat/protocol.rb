module Rat
  module Protocol
    @@initialized = []
    def self.initialized
      @@initialized
    end
  
  
    # To be inherited from for any +Protocol+. A +Rat+ +Protocol+ must expose at
    # least four things - an +::initialize+ method, a +::new+ (+#initialize+, in
    # other words) method, a +::terminate+ method, and a +#<<+ method.
    class Base
      def self.inherited klass
      
      end
    
      # One of the required methods in a +Protocol+ plugin, +::initialize+ is
      # run when +Rat+ starts (if there is a default connection set up involving
      # your protocol), when the first window is created for a protocol, or when the
      # protocol is otherwise initialized by +Rat+. It's perfect to
      # make any connections, declare presence, and so on. It will only be run
      # once, unless +::terminate+ is run and then the protocol is re-connected.
      # 
      # This should take a login argument, and optionally a password argument
      # (if relevant), and should eventually call `super`.
      def self.initialize # login, password = nil
        Protocol.initialized << self
      end
    
      # Provided by +Base+, and probably doesn't need to be modified - this
      # predicate will determine if your protocol has been globally initialized
      # by +Rat+ yet.
      def self.initialized?
        Protocol.initialized.include? self
      end
    
      # Required for every protocol, this method is run when +Rat+ closes down
      # itself, or, for some reason, closes the protocol.
      # 
      # This should eventually call `super`.
      def self.terminate
        Protocol.initialized.delete self
      end
    
      # The second required method, +::new+ (+#initialize+) is run when a window is
      # dedicated to a protocol. Should accept a window object (where incoming
      # messages or status information can be printed) and a target (that the user
      # specified, where messages should be sent or whatever is appropriate).
      # 
      # This should take window and target arguments, and eventually call
      # +super+ with those arguments.
      def initialize window, target
        @window = window
        @target = target
      end
    
      # Finally, a +#<<+ method that deals with outgoing messages, sending
      # them on their merry way or processing them in some way.
      #
      # Should recieve a message argument, and can optionally call +super+ to
      # simply print the target and message to the window.
      def << message
        @window << ['Rattagan', message].join(" > ")
      end
    end
  
    # This class applies to any window with no protocol.
    class None < Rat::Protocol::Base
      def self.initialize
        super
      end

      def self.terminate
        super
      end


      def initialize window, target
        super window, target
      end

      def << message
        super message
      end
    end
  end
end