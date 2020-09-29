# frozen_string_literal: true

Medlibra::Container.boot :utils, namespace: true do |system|
  init do
    require "concurrent-ruby"
    require "dry/inflector"
    require "jwt"
    require "curb"
    require "oj"
    require "redis"

  end

  start do
    use :monitor, :settings

    register "curl", Curl
    register "jwt", JWT
    register "oj", Oj
    register "inflector", Dry::Inflector.new
    register "redis", Redis.new(url: system[:settings].redis_url)

    register "jwt_keys", memo: true do
      Concurrent::Map.new
    end
  end
end
