# frozen_string_literal: true

require "oj"

module Shared
  module Web
    module TestHelpers
      def parsed_body
        Oj.load(last_response.body)
      end

      def make_request(method, path, auth_code:, params: {}, headers: {})
        auth_header = "Bearer #{auth_code}"
        headers["CONTENT_TYPE"] = "application/json"

        header "Authorization", auth_header
        public_send(
          method,
          path,
          params.to_json,
          headers,
        )
      end
    end
  end
end
