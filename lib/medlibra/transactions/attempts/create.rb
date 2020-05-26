# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Attempts
      class Create
        class IncorrectRelationError < StandardError
        end

        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.assessments_repo",
          "repositories.questions_repo",
          "services.find_user",
          "services.attempts.save_results",
          validate: "validations.attempts.for_create",
        ]

        def call(uid:, id:, params:) # rubocop:disable Metrics/MethodLength
          user = yield find_user.(uid)
          yield validate_assessment(id)
          params = yield validate_params(params)
          questions = get_questions_by_assessment(id)
          grouped_questions = questions.group_by(&:id)
          yield validate_relations(grouped_questions, params)
          score = calculate_score(grouped_questions, params)

          yield save_results.(
            params: params,
            user: user,
            score: score,
            assessment_id: id,
          )

          Success()
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
          return Failure(questions: ["should be an array"]) unless params.is_a?(Array)

          validate_call = validate.method(:call)
          results = params.map(&validate_call)
          failed = results.detect(&:failure?)

          if failed
            Failure(questions: ["should be correctly structured"])
          else
            get_values = ->(result) { result.values.to_h }
            Success(results.map(&get_values))
          end
        end

        def validate_relations(questions, params)
          params.each do |q|
            question = questions[q[:question_id]].first
            raise IncorrectRelationError unless question

            detector = ->(a) { a.id == q[:choosen_answer_id] }
            answer = question.answers.detect(&detector)
            raise IncorrectRelationError unless answer
          end

          Success()
        rescue IncorrectRelationError
          Failure(questions: ["incorrect relationships"])
        end

        def get_questions_by_assessment(id)
          questions_repo
            .questions
            .for_finish_validation(id)
            .to_a
        end

        def calculate_score(questions, params)
          questions_amount = questions.count
          correct_answers = count_correct_answers(questions, params)

          (correct_answers.to_f / questions_amount).round(2).to_f
        end

        def count_correct_answers(questions, params)
          params.select do |q|
            question_id = q[:question_id]
            answer_id = q[:choosen_answer_id]

            questions[question_id]
              .first
              .answers
              .detect { |answer| answer.id == answer_id }
              .correct
          end.count
        end
      end
    end
  end
end
