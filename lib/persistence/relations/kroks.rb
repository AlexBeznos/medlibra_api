# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Kroks < ROM::Relation[:sql]
      schema(:kroks, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :name, ::Types::Strict::String

        primary_key :id

        associations do
          has_many :fields
        end
      end
    end
  end
end
