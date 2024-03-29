# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Years < ROM::Relation[:sql]
      schema(:years, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :name, ::Types::Strict::String

        primary_key :id

        associations do
          has_many :assessments
        end
      end
    end
  end
end
