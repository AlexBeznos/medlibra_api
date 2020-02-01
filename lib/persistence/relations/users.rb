# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Users < ROM::Relation[:sql]
      schema(:users, infer: true) do
        attribute :username, ::Types::Strict::String
        attribute :helper_notifications_enabled, ::Types::Strict::Bool
        attribute :changes_notifications_enabled, ::Types::Strict::Bool
        attribute :learning_intensity, ::Types::LearningIntensities

        use :timestamps
      end
    end
  end
end
