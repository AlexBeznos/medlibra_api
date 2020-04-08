# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Answers < ROM::Relation[:sql]
      schema(:answers, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :title, ::Types::Strict::String
        attribute :correct, ::Types::Strict::Bool

        primary_key :id

        associations do
          belongs_to :question
        end
      end
    end
  end
end
