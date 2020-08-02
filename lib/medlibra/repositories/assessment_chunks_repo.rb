# frozen_string_literal: true

require "medlibra/repository"

module Medlibra
  module Repositories
    class AssessmentChunksRepo < Medlibra::Repository[:assessment_chunks]
      def create_with_questions(chunk)
        chunk = chunk.merge(
          created_at: Time.now.utc,
          updated_at: Time.now.utc,
        )

        assessment_chunks
          .combine(:chunk_questions)
          .command(:create)
          .call(chunk)
      end
    end
  end
end
