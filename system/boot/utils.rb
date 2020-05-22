# frozen_string_literal: true

Medlibra::Container.boot :utils, namespace: true do |system|
  init do
    require "concurrent-ruby"
    require "dry/inflector"
    require "jwt"
    require "curb"
    require "oj"
    require "sentry-raven"
  end

  start do
    use :settings

    register "curl", Curl
    register "jwt", JWT
    register "oj", Oj
    register "inflector", Dry::Inflector.new

    Raven.configure do |config|
      config.dsn = system[:settings].sentry_dsn
    end

    register "sentry", Raven

    register "jwt_keys", memo: true do
      Concurrent::Map.new
    end
  end
end
