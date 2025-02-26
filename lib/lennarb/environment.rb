module Lennarb
  class Environment
    NAMES = %i[development test production local]

    # Returns the name of the environment.
    # @parameter name [Symbol]
    #
    attr_reader :name

    # Initialize the environment.
    #  @parameter name [String, Symbol] The name of the environment.
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
    def ==(other) = name == other || name.to_s == other
    alias_method :eql?, :==
    alias_method :equal?, :==
    alias_method :===, :==

    # Returns the name of the environment as a symbol.
    # @returns [Symbol]
    #
    def to_sym = name

    # Returns the name of the environment as a string.
    # @returns [String]
    #
    def to_s = name.to_s

    # Returns the name of the environment as a string.
    # @returns [String]
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
