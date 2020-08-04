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
          "repositories.assessments_repo",
          "services.find_user"
        ]

        def call(uid:)
          user = yield find_user.(uid)
          exams = get_exams(user)

          Success([200, serialize_exams(exams)])
        end

        private

        def get_exams(user)
          assessments_repo.exams_page(
            krok_id: user.krok_id,
            field_id: user.field_id,
            user_id: user.id,
          )
        end

        def serialize_exams(exams)
          exams.map do |exam|
            {
              id: exam.id,
              year: exam.year.name,
              amount: exam.questions_amount,
              triesAmount: exam.attempts.count,
              score: exam.attempts.first&.score,
            }
          end
        end
      end
    end
  end
end
