# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Questions < ROM::Relation[:sql]
      schema(:questions, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :title, ::Types::Strict::String

        primary_key :id
      end
    end
  end
end
