# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module AssessmentChunks
      class Create
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.assessments_repo",
          "repositories.assessment_chunks_repo",
          "repositories.chunk_questions_repo",
          "services.find_user",
          validate: "validations.assessment_chunks.for_create",
        ]

        def call(uid:, id:, params:)
          user = yield find_user.(uid)
          yield validate_assessment(id)
          params = yield validate_params(params)
          chunks = persist_chunks(id, user, params)

          Success(prepare_response(chunks))
        end

        private

        def validate_assessment(id)
          exist =
            assessments_repo
            .assessments
            .exist?(id: id)

          if exist
            Success()
          else
            Failure(assessment: ["is not exist"])
          end
        end

        def validate_params(params)
          result = validate.(params)

          if result.success?
            Success(result.values)
          else
            Failure(result.errors.to_h)
          end
        end

        def persist_chunks(id, user, params)
          assessment = assessments_repo.by_id_for_chunks(id)
          chunks = []

          assessment.questions.each_slice(params[:chunk_size]) do |questions|
            chunks << persist_chunk(questions, user)
          end

          chunks
        end

        def persist_chunk(questions, user)
          chunk_questions = questions.map do |q|
            { question_id: q.id }
          end

          chunk_params = {
            user_id: user.id,
            assessment_id: questions.first.assessment_id,
            chunk_questions: chunk_questions,
          }

          assessment_chunks_repo
            .create_with_questions(chunk_params)
        end

        def prepare_response(chunks)
          {
            questionChunkIds: chunks.map(&:id),
          }
        end
      end
    end
  end
end
