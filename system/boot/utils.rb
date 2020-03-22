# frozen_string_literal: true

Medlibra::Container.boot :utils, namespace: true do |_app|
  init do
    require "concurrent-ruby"
    require "dry/inflector"
    require "jwt"
    require "curb"
    require "oj"
  end

  start do
    register "curl", Curl
    register "jwt", JWT
    register "oj", Oj
    register "inflector", Dry::Inflector.new
    register "jwt_keys", memo: true do
      Concurrent::Map.new
    end
  end
end
