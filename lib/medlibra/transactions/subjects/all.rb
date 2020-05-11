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
            .assessments
            .where(krok_id: user.krok_id)
            .where(field_id: user.field_id)
            .where(subfield_id: subfield_id)
            .combine(:year)
            .to_a
            .group_by(&:year)
        end

        def serialize_year_assessments(years)
          years.map do |year, assessments|
            {
              year: year.name,
              triesAmount: 0,
              score: 0,
            }
              .merge(find_exam(assessments))
              .merge(find_training(assessments))
          end
        end

        def find_exam(assessments)
          find_and_serializer_assessment(
            assessments,
            "training-exam",
            "exam",
          )
        end

        def find_training(assessments)
          find_and_serializer_assessment(
            assessments,
            "training",
            "training",
          )
        end

        def find_and_serializer_assessment(assessments, type, key)
          record = assessments.detect do |r|
            r.type == ::Types::AssessmentTypes[type]
          end

          return { key => nil } unless record

          {
            key => {
              id: record.id,
              amount: record.questions_amount,
            },
          }
        end
      end
    end
  end
end
