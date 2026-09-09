module Lennarb
  # Manage the environment of the application.
  #
  # @example
  #  app.env.development? # => true
  #  app.env.test? # => false
  #
  class Environment
    # Returns the name of the environment.
    # @param name [Symbol]
    #
    attr_reader :name

    # Initialize the environment.
    #  @param name [String, Symbol] The name of the environment.
    #
    def initialize(name)
      @name = name.to_sym

      return if NAMES.include?(@name)

      raise ArgumentError, "Invalid environment: #{@name.inspect}"
    end

    # Returns true if the environment is development.
    #
    def development? = name == :development

    # Returns true if the environment is test.
    #
    def test? = name == :test

    # Returns true if the environment is production.
    #
    def production? = name == :production

    # Returns true if the environment is local (either `test` or `development`).
    #
    def local? = test? || development?

    # Implements equality for the environment.
    #
    # Compares by name, so an environment equals its name as a Symbol or a
    # String, and equals another environment with the same name.
    #
    # `equal?` is deliberately not aliased here: in Ruby it means object
    # identity and overriding it broke that contract in both directions.
    #
    def ==(other) = name == other || name.to_s == other.to_s
    alias_method :===, :==

    # Value equality, kept consistent with {#hash} so an environment behaves as
    # a Hash key.
    #
    # @param other [Object]
    # @return [Boolean]
    #
    def eql?(other) = other.is_a?(Environment) && name == other.name

    # @return [Integer]
    #
    def hash = name.hash

    # Returns the name of the environment as a symbol.
    # @return [Symbol]
    #
    def to_sym = name

    # Returns the name of the environment as a string.
    # @return [String]
    #
    def to_s = name.to_s

    # Returns the name of the environment as a string.
    # @return [String]
    def inspect = to_s.inspect

    # Yields a block if the environment is the same as the given environment.
    # - To match all environments use `:any` or `:all`.
    # - To match local environments use `:local`.
    # @param envs [Array<Symbol>] The environment(s) to check.
    #
    # @example
    #   app.env.on(:development) do
    #     # Code to run in development
    #   end
    def on(*envs)
      matched = envs.include?(:any) ||
        envs.include?(:all) ||
        envs.include?(name) ||
        (envs.include?(:local) && local?)

      yield if matched
    end
  end
end
