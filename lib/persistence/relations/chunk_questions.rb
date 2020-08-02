# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class ChunkQuestions < ROM::Relation[:sql]
      schema(:chunk_questions, infer: true) do
        attribute :id, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :assessment_chunk
          belongs_to :question
        end
      end
    end
  end
end
