# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Questions
      class Get
        DEFAULT_LIMIT = 10
        DEFAULT_OFFSET = 0

        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.assessments_repo",
          "repositories.questions_repo",
          "repositories.bookmarks_repo",
          "services.find_user",
          "services.pagination_meta",
          validate: "validations.for_pagination",
        ]

        def call(uid:, id:, params:)
          user = yield find_user.(uid)
          yield validate_assessment(id)
          params = yield validate_params(params)
          meta = get_pagination_meta(id, params)
          questions = get_questions(user, id, **params)

          Success(meta.merge(serialize_questions(questions)))
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
          return Failure(result.errors.to_h) if result.failure?

          params = result.values.to_h

          Success(
            limit: params.fetch(:limit, DEFAULT_LIMIT),
            offset: params.fetch(:offset, DEFAULT_OFFSET),
          )
        end

        def get_pagination_meta(id, params)
          query =
            questions_repo
            .questions
            .by_assessment(id)

          pagination_meta
            .call(query, **params)
        end

        def get_questions(user, id, limit:, offset:)
          questions_repo
            .questions
            .questions_page(
              user_id: user.id,
              assessment_id: id,
              limit: limit,
              offset: offset,
            ).to_a
        end

        def serialize_questions(questions) # rubocop:disable Metrics/MethodLength
          {
            questions: questions.map do |question|
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
            end,
          }
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
