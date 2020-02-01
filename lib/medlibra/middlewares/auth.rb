# frozen_string_literal: true

require "rack"
require "medlibra/container"

module Medlibra
  module Middlewares
    class Auth
      AUTH_HEADER_NAME = "HTTP_AUTHORIZATION"
      TOKEN_TYPE = "Bearer"
      UNAUTHORIZED_STATUS = 401

      def initialize(app = nil)
        @app = app
      end

      def call(env)
        auth_header = fetch_auth_header(env)
        return unauthorized unless auth_header

        type, token = auth_header.split("\s")
        return unauthorized if type != TOKEN_TYPE

        payload, = Container["services.decode_jwt"].(token)
        return unauthorized unless payload

        @app.call(env.merge("firebase.uid" => payload["sub"]))
      end

      private

      def fetch_auth_header(env)
        Rack::Request
          .new(env)
          .fetch_header(AUTH_HEADER_NAME)
      rescue KeyError
        false
      end

      def unauthorized
        [
          UNAUTHORIZED_STATUS,
          {},
          [],
        ]
      end
    end
  end
end
