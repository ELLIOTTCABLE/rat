unless defined? Spec
  module Spec
    module ::Kernel
      
      def describe object, &block
        # Do nothing with the block
      end
      
    end
  end
end