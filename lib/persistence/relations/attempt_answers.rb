# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class AttemptAnswers < ROM::Relation[:sql]
      schema(:attempt_answers, infer: true) do
        attribute :id, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :question
          belongs_to :answer
          belongs_to :attempt
        end
      end
    end
  end
end
