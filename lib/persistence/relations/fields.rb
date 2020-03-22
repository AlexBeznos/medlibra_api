# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Fields < ROM::Relation[:sql]
      schema(:fields, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :name, ::Types::Strict::String

        primary_key :id

        associations do
          belongs_to :krok
        end
      end
    end
  end
end
