# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class AssessmentQuestions < ROM::Relation[:sql]
      schema(:assessment_questions, infer: true) do
        attribute :id, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :question
          belongs_to :assessment
        end
      end
    end
  end
end
