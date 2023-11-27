# frozen_string_literal: true

module Lennarb
  # The ArrayExtensions module is used to add the wrap method to the Array
  # class.
  #
  module ArrayExtensions
    # Wraps the object in an array if it is not already an array.
    #
    # @param object [Object] the object to wrap
    #
    # @return [Array] the wrapped object
    #
    def wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end

Array.extend(Lennarb::ArrayExtensions)
