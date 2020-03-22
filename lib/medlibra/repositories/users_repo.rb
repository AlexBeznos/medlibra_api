# frozen_string_literal: true

require "medlibra/repository"

module Medlibra
  module Repositories
    class UsersRepo < Medlibra::Repository[:users]
      commands :create, :update

      def by_uid(uid)
        users
          .where(uid: uid)
          .one
      end
    end
  end
end
