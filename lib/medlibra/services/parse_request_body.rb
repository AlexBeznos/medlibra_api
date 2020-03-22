# frozen_string_literal: true

require "oj"

require "medlibra/import"

module Medlibra
  module Services
    class ParseRequestBody
      include Import["utils.inflector"]

      def call(string)
        body = Oj.load(string)
        deep_transform_keys(body)
      end

      private

      def deep_transform_keys(input) # rubocop:disable Metrics/MethodLength
        case input
        when Array
          input.map(&method(:deep_transform_keys))
        when Hash
          input.map do |key, value|
            [
              inflector.underscore(key),
              deep_transform_keys(value),
            ]
          end.to_h
        else
          input
        end
      end
    end
  end
end
