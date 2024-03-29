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

          Success([201, prepare_response(chunks)])
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
          chunk_params = {
            user_id: user.id,
            assessment_id: questions.first.assessment_id,
          }

          assessment_chunks_repo.transaction do
            commit_chunk(chunk_params).tap do |chunk|
              questions.each(&commit_chunk_question(chunk))
            end
          end
        end

        def commit_chunk_question(chunk)
          lambda do |question|
            chunk_questions_repo
              .chunk_questions
              .changeset(
                :create,
                question_id: question.id,
                assessment_chunk_id: chunk.id,
              )
              .commit
          end
        end

        def commit_chunk(params)
          assessment_chunks_repo
            .assessment_chunks
            .changeset(:create, **params)
            .map(:add_timestamps)
            .commit
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
