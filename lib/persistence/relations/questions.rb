# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Questions < ROM::Relation[:sql]
      schema(:questions, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :title, ::Types::Strict::String

        primary_key :id

        associations do
          has_one :assessment_questions
          has_one :assessments, through: :assessment_questions
          has_many :chunk_questions
          has_many :assessment_chunks, through: :chunk_questions
          has_many :answers
          has_many :bookmarks
          belongs_to :subfield
        end
      end

      def by_assessment(id)
        join(assessments)
          .where(assessments[:id] => id)
      end

      def questions_page(user_id:, assessment_id:, limit:, offset:)
        by_assessment(assessment_id)
          .order { id.asc }
          .limit(limit)
          .offset(offset)
          .combine(:answers)
          .combine(:subfield)
          .combine(:bookmarks)
          .node(:bookmarks) { |b| b.where(user_id: user_id) }
      end

      def chunks_page(chunk_id:, user_id:)
        join(assessment_chunks)
          .where(assessment_chunks[:id] => chunk_id)
          .combine(:answers)
          .combine(:subfield)
          .combine(:bookmarks)
          .node(:bookmarks) { |b| b.where(user_id: user_id) }
      end

      def for_finish_validation(assessment_id)
        join(assessment_questions)
          .where(assessment_questions[:assessment_id] => assessment_id)
          .combine(:answers)
          .node(:answers) do |answers|
            answers.select(:id, :question_id, :correct)
          end.select(:id)
      end
    end
  end
end
