# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Attempts < ROM::Relation[:sql]
      schema(:attempts, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :score, ::Types::Strict::Float

        primary_key :id

        associations do
          belongs_to :user
          belongs_to :assessment
        end
      end
    end
  end
end
