# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class AssessmentChunks < ROM::Relation[:sql]
      schema(:assessment_chunks, infer: true) do
        attribute :id, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :user
          belongs_to :assessment

          has_many :chunk_questions
          has_many :questions, through: :chunk_questions
        end
      end
    end
  end
end
