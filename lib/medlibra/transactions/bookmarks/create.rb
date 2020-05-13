# frozen_string_literal: true

require "dry/monads"
require "dry/monads/do"
require "medlibra/import"

module Medlibra
  module Transactions
    module Bookmarks
      class Create
        include Dry::Monads[:result]
        include Dry::Monads::Do.for(:call)
        include Import[
          "repositories.bookmarks_repo",
          "services.find_user",
          validate: "validations.bookmarks.for_create",
        ]

        def call(uid:, params:)
          user = yield find_user.(uid)
          params = yield validate_params(params)

          create_bookmark(params, user)

          Success()
        end

        private

        def validate_params(params)
          result = validate.(params)

          if result.success?
            Success(result.values)
          else
            Failure(result.errors.to_h)
          end
        end

        def create_bookmark(params, user)
          bookmarks_repo
            .bookmarks
            .changeset(:create, params.merge(user_id: user.id))
            .map(:add_timestamps)
            .commit
        end
      end
    end
  end
end
