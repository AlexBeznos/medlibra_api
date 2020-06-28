# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Subjects
      class All
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.assessments_repo",
          "repositories.subfields_repo",
          "repositories.years_repo",
          "services.find_user"
        ]

        def call(uid:, id:)
          user = yield find_user.(uid)
          yield validate_subfield(id)

          years_assessments = find_year_assessmets(user, id)

          Success(serialize_year_assessments(years_assessments))
        end

        private

        def validate_subfield(id)
          exist =
            subfields_repo
            .subfields
            .exist?(id: id)

          if exist
            Success()
          else
            Failure(subject: ["is not exist"])
          end
        end

        def find_year_assessmets(user, subfield_id)
          assessments_repo
            .subfields_page(
              krok_id: user.krok_id,
              field_id: user.field_id,
              subfield_id: subfield_id,
              user_id: user.id,
            ).group_by(&:year)
        end

        def serialize_year_assessments(years)
          years.map do |year, assessments|
            {
              year: year.name,
            }
              .merge(attempt_attributes(assessments))
              .merge(find_training(assessments))
          end
        end

        def find_training(assessments)
          record = assessments.detect do |r|
            r.type == "training"
          end

          return { training: nil } unless record

          {
            training: {
              id: record.id,
              amount: record.questions_amount,
            },
          }
        end

        def attempt_attributes(assessments)
          record = assessments.detect do |r|
            r.type == ::Types::AssessmentTypes["training"]
          end

          {
            triesAmount: record.attempts.count,
            score: record.attempts.first&.score,
          }
        end
      end
    end
  end
end
