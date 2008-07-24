module Rat
  # Contains a single gorified hash, an array of Rat::Configuration instances.
  # Each instance has a key, an array of categories, and a value of some sort.
  # TODO: Rename to Rat::Setting, or something similar -
  # +Rat::Configuration.new+ doesn't really make much semantic sense.
  class Configuration
    class <<self
      @@settings = {}
      
      # Dumps current configuration to a file. Doesn't save any default
      # setting, doesn't save any empty categories.
      # TODO: Implement this
      def dump file
        
      end
      
      # Imports configuration from a file. (See +::dump+.)
      # TODO: Implement this
      def import file
        
      end
      
      # Retrieves a setting's value, by key and categories
      # TODO: Implement this
      def get key, categories = []
        key, categories = parse key, categories

      end
      
      # Retrieves either a key
      # TODO: Implement this
      # TODO: Use a special Rat::Configuration::Category class or something 
      #   instead of the current @@settings hash in order to store
      #   configuration variables and other categories, so [][][] returns the
      #   value of the key instead of a setting class instance.
      def [] key
        
      end
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
      
      category = @categories.inject(@@settings) {|hash, category| hash[:category] ||= {} }
      raise 'there is already a category or setting key by that name' if category.include? key
      category[key] = self
    end
    
    private
      
      # Parses a key string or symbol into an actual key and a list of
      # categories. Takes a string or symbol and any extra categories, and
      # returns an array of the key and categories.
      def parse key, precategories = []
        categories = key.split "/"
        key = categories.pop!
        categories = precategories + categories
        
        [key.to_sym, categories.map! {|c|c.to_sym}]
      end
      
  end
end