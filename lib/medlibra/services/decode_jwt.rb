# frozen_string_literal: true

require "medlibra/import"

module Medlibra
  module Services
    class DecodeJwt
      JWT_ALG = { algorithm: "RS256" }.freeze

      include Import[
        "utils.jwt",
        "services.fetch_jwt_key",
        validate_header: "validations.jwt.header",
        validate_payload: "validations.jwt.payload",
      ]

      def call(token)
        return unless valid_token?(token)

        cert = fetch_jwt_key.(header["kid"])
        return unless cert

        jwt.decode(token, public_key(cert), true, JWT_ALG)
      rescue JWT::DecodeError
        false
      end

      private

      def public_key(cert)
        OpenSSL::X509::Certificate
          .new(cert)
          .public_key
      end

      def valid_token?(token)
        payload, header = jwt.decode(token, nil, false, JWT_ALG)

        return false unless valid_header?(header)
        return false unless valid_payload?(payload)

        true
      end

      def valid_header?(header)
        validate_header
          .call(header)
          .success?
      end

      def valid_payload?(payload)
        validate_payload
          .call(payload)
          .success?
      end
    end
  end
end
