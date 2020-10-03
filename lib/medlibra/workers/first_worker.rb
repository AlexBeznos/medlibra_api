# frozen_string_literal: true

require "sidekiq"
require "medlibra/container"
require "medlibra/import"

module Medlibra
  module Workers
    class FirstWorker
      include Sidekiq::Worker
      include Import["repositories.users_repo"]

      def perform(uid)
        p users_repo.by_uid(uid)
      end
    end
  end
end
