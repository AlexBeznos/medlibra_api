# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Subjects
      class Get
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.subfields_repo",
          "services.find_user"
        ]

        def call(uid:)
          user = yield find_user.(uid)
          subjects = get_subjects(user)

          Success(subjects.map(&:to_h))
        end

        private

        def get_subjects(user)
          subfields_repo
            .subjects_page(
              krok_id: user.krok_id,
              field_id: user.field_id,
            )
        end
      end
    end
  end
end
