# frozen_string_literal: true

Medlibra::Container.boot :settings, from: :system do
  before :init do
    require "types"
  end

  settings do
    key :session_secret, Types::Strict::String.constrained(filled: true)
    key :database_url, Types::Strict::String.constrained(filled: true)
    key :firebase_project_id, Types::Strict::String.constrained(filled: true)
    key :sentry_dsn, Types::Strict::String.constrained(filled: true)
    key :redis_url, Types::Strict::String.constrained(filled: true)
  end
end
