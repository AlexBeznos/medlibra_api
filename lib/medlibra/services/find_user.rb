# frozen_string_literal: true

require "dry/monads"
require "medlibra/import"

module Medlibra
  module Services
    class FindUser
      include Dry::Monads[:result]
      include Import["repositories.users_repo"]

      def call(uid)
        user = users_repo.by_uid(uid)

        if user
          Success(user)
        else
          Failure(["user doesn't exist"])
        end
      end
    end
  end
end
