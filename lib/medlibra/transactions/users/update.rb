# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Users
      class Update
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.users_repo",
          "services.find_user",
          validation: "validations.users.for_update",
        ]

        def call(params:, uid:)
          user = yield find_user.(uid)
          values = yield validate(params.merge(user: user))
          yield update_user(user, values)

          Success()
        end

        private

        def validate(params)
          result = validation.(params)

          if result.success?
            Success(result.to_h)
          else
            Failure(result.errors.to_h)
          end
        end

        def update_user(user, values)
          users_repo
            .users
            .by_pk(user.id)
            .changeset(:update, **values)
            .map(:touch)
            .commit

          Success()
        end
      end
    end
  end
end
