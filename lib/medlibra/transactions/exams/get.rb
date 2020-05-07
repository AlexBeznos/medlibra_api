# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Exams
      class Get
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.users_repo",
          "repositories.assessments_repo",
        ]

        def call(uid:)
          user = yield get_user(uid)
          exams = yield get_exams(user)

          Success(serialize_exams(exams))
        end

        private

        def get_user(uid)
          user = users_repo.by_uid(uid)

          if user
            Success(user)
          else
            Failure(error: "user doesn't exist")
          end
        end

        def get_exams(user)
          exams = assessments_repo.exams(
            krok_id: user.krok_id,
            field_id: user.field_id,
          )

          Success(exams)
        end

        def serialize_exams(exams)
          exams.map do |exam|
            {
              id: exam.id,
              year: exam.year.name,
              amount: exam.questions_amount,
              triesAmount: 0,
              score: 0,
            }
          end
        end
      end
    end
  end
end
