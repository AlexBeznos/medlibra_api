# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Users
      class Create
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.users_repo",
          validation: "validations.users.for_create",
        ]

        def call(params:)
          values = yield validate(params)
          yield create_user(values)

          Success()
        end

        def validate(params)
          result = validation.(params)

          if result.success?
            Success(result.to_h)
          else
            Failure(result.errors.to_h)
          end
        end

        def create_user(params)
          users_repo
            .users
            .changeset(:create, **params)
            .map(:add_timestamps)
            .commit

          Success()
        end
      end
    end
  end
end
