require "medlibra/import"

module Medlibra
  module Services
    class FetchJwtKey
      KEY_URL = "https://www.googleapis.com/"\
                "robot/v1/metadata/x509/"\
                "securetoken@system.gserviceaccount.com".freeze

      include Import[
        "utils.curl",
        "utils.oj",
        "utils.jwt_keys",
      ]

      def call(key)
        fetch_keys if jwt_keys.empty?
        clear_and_fetch_keys if Time.now > Time.at(jwt_keys["exp_at"])

        jwt_keys[key]
      end

      private

      def fetch_keys
        resp = curl.get(KEY_URL)
        exp_at = get_exp_at(resp.header_str)
        return unless exp_at

        jwt_keys.put("exp_at", exp_at)

        oj.load(resp.body_str).each do |key, cert|
          jwt_keys.put(key, cert)
        end
      end

      def get_exp_at(header_str)
        cache_str = header_str.
          split(/[\r\n]+/).
          find(&method(:cache_control_matcher))

        exp_in = cache_str.match(/max\-age\=(\d+)\,/)
        return unless exp_in

        Time.now.to_i + exp_in[1].to_i
      end

      def cache_control_matcher(str)
        str.match(/C|cache\-control\:/)
      end

      def clear_and_fetch_keys
        jwt_keys.clear
        fetch_keys
      end
    end
  end
end
