# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module AssessmentChunks
      class Get
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.questions_repo",
          "repositories.assessment_chunks_repo",
          "services.find_user",
        ]

        def call(uid:, id:)
          user = yield find_user.(uid)
          chunk = yield find_chunk(user, id)
          questions = find_questions(user, chunk)

          Success([200, serialize_questions(questions)])
        end

        private

        def find_chunk(user, id)
          query = assessment_chunks_repo
                  .assessment_chunks
                  .where(user_id: user.id)
                  .where(id: id)
                  .select(:id)

          Success(query.one!)
        rescue ROM::TupleCountMismatchError
          Failure({ assessment_chunk: ["is not exist"] })
        end

        def find_questions(user, chunk)
          questions_repo
            .questions
            .chunks_page(chunk_id: chunk.id, user_id: user.id)
            .to_a
        end

        def serialize_questions(questions) # rubocop:disable Metrics/MethodLength
          questions.map do |question|
            {
              id: question.id,
              title: question.title,
              bookmarked: question.bookmarks.any?,
              subject: serialize_subfield(question.subfield),
              answers: question.answers.map do |answer|
                {
                  id: answer.id,
                  title: answer.title,
                  isCorrect: answer.correct,
                }
              end,
            }
          end
        end

        def serialize_subfield(subfield)
          return unless subfield

          {
            id: subfield.id,
            title: subfield.name,
          }
        end
      end
    end
  end
end
