module Lennarb
  # The Routting module.
  #
  module Routing
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Define a route for the GET HTTP method
      #
      # @param path [String]
      # @param block [Proc]
      #
      # @return [void]
      #
      def routes(&block)
        helpers_mod = respond_to?(:helpers_module) ? helpers_module : Module.new
        @routes ||= Routes.new(helpers_mod, &block)
      end

      # Define a route for the GET HTTP method
      #
      # @param path [String]
      # @param block [Proc]
      #
      # @return [void]
      #
      HTTP_METHODS.each do |http_method|
        define_method(http_method.downcase) do |path, &block|
          routes.send(http_method.downcase, path, &block)
        end
      end
    end

    # Proxy method to the class method
    #
    # @see {ClassMethods#routes}
    #
    def routes(&block)
      self.class.routes(&block)
    end
  end
end
