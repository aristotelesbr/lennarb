# frozen_string_literal: true

module Lennarb
  module ArrayExtensions
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
