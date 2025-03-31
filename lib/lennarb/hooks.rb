module Lennarb
  # The Hooks class provides a mechanism to register and execute
  # before and after hooks around certain operations.
  class Hooks
    # @return [Array<Proc>] the list of before hooks
    attr_reader :before_hooks

    # @return [Array<Proc>] the list of after hooks
    attr_reader :after_hooks

    # Initializes a new Hooks instance.
    #
    # @param helpers_module [Module] a module containing helper methods to be included in the hook context
    def initialize(helpers_module = Module.new)
      @before_hooks = []
      @after_hooks = []
      @context_module = Module.new do
        include helpers_module
        attr_accessor :req, :res
      end
    end

    # Registers a block to be executed before the main operation.
    #
    # @yield the block to be executed before
    def before(&block)
      @before_hooks << wrap_block(&block) if block_given?
    end

    # Registers a block to be executed after the main operation.
    #
    # @yield the block to be executed after
    def after(&block)
      @after_hooks << wrap_block(&block) if block_given?
    end

    # Executes all registered before hooks with the given request and response.
    #
    # @param req [Request] the request object
    # @param res [Response] the response object
    def run_before_hooks(req, res)
      @before_hooks.each { |hook| hook.call(req, res) }
    end

    # Executes all registered after hooks with the given request and response.
    #
    # @param req [Request] the request object
    # @param res [Response] the response object
    def run_after_hooks(req, res)
      @after_hooks.each { |hook| hook.call(req, res) }
    end

    private

    # Wraps a block in a context that includes helper methods and request/response accessors.
    #
    # @yield the block to be wrapped
    # @return [Proc] the wrapped block
    def wrap_block(&block)
      context_module = @context_module
      proc do |req, res|
        context = Object.new.extend(context_module)
        context.req = req
        context.res = res
        context.instance_exec(req, res, &block)
      end
    end
  end
end
