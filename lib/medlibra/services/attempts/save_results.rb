# frozen_string_literal: true

require "dry/monads"
require "medlibra/import"

module Medlibra
  module Services
    module Attempts
      class SaveResults
        include Dry::Monads[:result]

        include Import[
          "repositories.attempts_repo",
          "repositories.attempt_answers_repo",
        ]

        def call(params:, **rest)
          attempts_repo.attempts.transaction do
            attempt = save_attempt(prepare_attempt_params(**rest))

            save_answers(params, attempt.id)
          end

          Success()
        rescue ROM::SQL::ConstraintError
          Failure(questions: ["incorrect relationships"])
        end

        private

        def save_attempt(params)
          attempts_repo
            .attempts
            .changeset(:create, params)
            .map(:add_timestamps)
            .commit
        end

        def prepare_attempt_params(score:, user:, assessment_id:)
          {
            score: score,
            user_id: user.id,
            assessment_id: assessment_id,
          }
        end

        def save_answers(params, attempt_id)
          params.each do |p|
            save_answer(
              question_id: p[:question_id],
              answer_id: p[:choosen_answer_id],
              attempt_id: attempt_id,
            )
          end
        end

        def save_answer(params)
          attempt_answers_repo
            .attempt_answers
            .changeset(:create, params)
            .commit
        end
      end
    end
  end
end
