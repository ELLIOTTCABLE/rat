module Rat
  # Contains a single nested Rat::Configuration::Category (a gorified hash, an
  # array of Rat::Configuration::Setting) instances. Each instance has a key,
  # an array of categories, and a value of some sort.
  module Configuration
    class Category < Hash
      # Like Hash#[], but returns the *value* of the object instead of the
      # object if the object is a Rat::Configuration::Setting
      def [] key
        contents = super key
        return contents.value if contents.is_a?(Rat::Configuration::Setting)
        contents
      end
      
      # Like Hash#[]=, but sets the *value* of the object instead of the
      # object if the object is a Rat::Configuration::Setting
      def []= key, value
        # Using #values_at, because we've overwritten #[]
        old_contents = begin
          self.fetch(key)
        rescue IndexError
          nil
        end
        if old_contents.is_a? Rat::Configuration::Setting
           old_contents.value = value
        else
          super key, value
        end
      end
    end
    
    class Setting
      # Retrieves either a key or a category
      def self.[] key
        Rat::Configuration::settings[key]
      end
      
      # The 'name' of the setting, is used in all references to it. Should be
      # a Symbol.
      # 
      # Can not be changed, because it is used to index the location of the
      # setting in the configuration.
      attr_reader :key
      
      # An array of categories to which the key belongs - these are
      # intrepolated as nested, as each setting can only exist in one
      # location.
      # 
      # Can not be changed, because it is used to index the location of the
      # setting in the configuration.
      attr_reader :categories
      
      # The default value for this setting
      attr_accessor :default
      
      # Sets the value to the setting's default value
      def default!
        @is_set = false
        @value = @default
      end
      
      attr_accessor :value
      
      # Sets the value of the setting
      def value= new_value
        @is_set = true
        @value = new_value
      end
      
      # Creates a new configuration variable. Takes a key (like in a normal
      # hash), and can be given a self-yielding block to set other things
      # (like a default value or categories).
      def initialize key
        key, categories = parse key
        
        @key = key
        @categories = categories
        
        @default = nil
        @value = nil
        @is_set = false
        
        yield self if block_given?
        
        cat = category! @categories
        raise 'there is already a category or setting key by that name' if cat.include? key
        cat[key] = self
      end
      
      private
      
        # Parses a key string or symbol into an actual key and a list of
        # categories. Takes a string or symbol and any extra categories, and
        # returns an array of the key and categories.
        def parse key, precategories = []
          categories = key.to_s.split "/"
          key = categories.pop
          categories = precategories + categories

          [key.to_sym, categories.map! {|c|c.to_sym}]
        end
        
        # Returns a single category (hash) given an array of categories to dig
        # through for it.
        def category categories, destructive = false
          categories.inject(Configuration::settings) do |hash, category|
            case hash[category]
            when nil
              raise "category '#{category}' does not exist" unless destructive
              hash[category] = Category.new if destructive
              
            when Rat::Configuration
              raise "'#{category}' is a setting key, not a category key"
              
            when Hash
              hash[category]
              
            else
              raise "key has unknown value of class #{hash[category].class}: #{hash[category].inspect}"
            end
          end
        end
        
        # Returns a single category (hash) given an array of categories to dig
        # through for it. Is 'destructive', in that it will create any empty
        # categories necessary. Will not overwrite setting keys, however.
        def category! categories
          category categories, true
        end
        
    end
    
    @@settings = Rat::Configuration::Category.new
    def self.settings
      @@settings
    end
    
    class <<self
      
      # Dumps current configuration to a file. Doesn't save any default
      # setting, doesn't save any empty categories.
      # TODO: Implement this
      def dump file
        
      end
      
      # Imports configuration from a file. (See +::dump+.)
      # TODO: Implement this
      def import file
        
      end
      
    end
  end

end