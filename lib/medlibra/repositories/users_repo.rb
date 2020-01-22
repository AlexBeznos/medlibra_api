# frozen_string_literal: true

require "medlibra/repository"

module Medlibra
  module Repositories
    class UsersRepo < Medlibra::Repository[:users]
      commands :create
    end
  end
end

