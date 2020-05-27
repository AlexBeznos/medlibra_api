# frozen_string_literal: true

require "dry/web/container"
require "dry/system/components"
require "dry-monitor"

Dry::Monitor.load_extensions(:rack)

module Medlibra
  class Container < Dry::Web::Container
    configure do
      config.name = :medlibra
      config.listeners = true
      config.default_namespace = "medlibra"
      config.auto_register = %w[lib/medlibra]
      config.heroku = ENV["HEROKU_APP_NAME"] == "medlibra-stage"
    end

    load_paths! "lib"
  end
end
