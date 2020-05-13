# frozen_string_literal: true

require "oj"

module Shared
  module Web
    module TestHelpers
      def parsed_body
        @parsed_body ||= Oj.load(last_response.body)
      end

      def reload_parsed_body!
        @parsed_body = nil
        parsed_body
      end

      def make_request(method, path, auth_code: nil, params: {}, headers: {})
        headers["CONTENT_TYPE"] = "application/json"

        params = if %i[post put].include?(method)
                   params.to_json
                 else
                   params
                 end

        if auth_code
          auth_header = "Bearer #{auth_code}"
          header "Authorization", auth_header
        end

        public_send(
          method,
          path,
          params,
          headers,
        )
      end
    end
  end
end
