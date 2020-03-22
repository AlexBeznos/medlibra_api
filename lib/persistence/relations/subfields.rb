# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Subfields < ROM::Relation[:sql]
      schema(:subfields, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :name, ::Types::Strict::String

        primary_key :id
      end
    end
  end
end
