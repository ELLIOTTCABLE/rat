require 'yaml'

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
      
      # Like Hash#[], but takes a linear path of sub-categories as an
      # argument, and recursively queries those categories
      def get key, categories = []
        if categories.empty?
          fetch key
        else
          cat = categories.shift
          fetch(cat).get(key, categories)
        end
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
        case
        if old_contents.is_a? Rat::Configuration::Setting
           old_contents.value = value
        else
          super key, Configuration::Setting.new(key) {|c| c.value = item }
        end
      end
      
      # Recursively converts a setting category to a plain hash. Ignores any
      # setting that hasn't changed from its default value, and empty
      # categories.
      def to_hash
        
        inject(Hash.new) do |hash, (key, item)|
          case item
          when Rat::Configuration::Setting
            hash[key] = item.value unless item.default?
            
          when Rat::Configuration::Category
            item = item.to_hash
            hash[key] = item unless item.empty?
            
          else
            hash[key] = item
          end
          
          hash
        end
        
      end
      
      # Recursively converts a plain hash to settings categories and settings
      # values.
      def self.from_hash(hash)
        
        hash.inject(new) do |h, (key, item)|
          case item
          when Hash
            h[key] = from_hash item
            
          else
            # See +#[]=+
            h[key] = item
          end
        end
        
      end
    end
    
    class Setting
      # See +Rat::Configuration::Category#[]+
      def self.[] key
        Rat::Configuration::settings[key]
      end
      
      # See +Rat::Configuration::Category#[]=+
      def self.[]= key, value
        Rat::Configuration::settings[key] = value
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
      
      def default?; !@is_set; end
      def set?; @is_set; end
      
      # The current value of the setting; i.e. what it is currently 'set' to
      attr_accessor :value
      
      # Sets the value of the setting
      def value= value
        raise ArgumentError, 'a setting can\'t be set to a Setting!' if value.is_a? Configuration::Setting
        @is_set = true
        @value = value
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
        
        default!
        
        cat = category! @categories
        raise 'there is already a category or setting key by that name' if cat.include? key
        cat[key] = self
        @categories.freeze
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
      def dump filename
        File.open(filename, File::WRONLY|File::TRUNC|File::CREAT) do |file|
          file.puts YAML::dump(@@settings.to_hash)
        end
      end
      
      # Imports configuration from a file. (See +::dump+.)
      # TODO: Implement this
      def load filename
        File.open(filename, File::RDONLY|File::CREAT) do |file|
          from_hash YAML::load(file.read)
        end
      end
      
    end
  end

end

# -- -- -- -- ! -- -- -- -- #
# Some stuff while I test...
# Note to self: Remember not to commit this!

include Rat
Configuration::Setting.new :foo
Configuration::Setting.new :bar do |setting|
  setting.default = "arf! arf!"
end
Configuration::Setting.new :gaz do |setting|
  setting.default = 42.42
end
Configuration::Setting.new "omg/lol"
Configuration::Setting.new :wtf do |setting|
  setting.default = [127, 0, 0, 1]
  setting.categories << :omg
end

# Configuration::Setting[:foo] = "lol, woot!"
# Configuration::Setting[:bar] = "Day Break is pretty full of win"
# Configuration::Setting[:gaz] = 1337
# Configuration::Setting[:omg][:wtf] = :categorized
# Configuration::Setting[:omg][:lol] = "also_categorized"