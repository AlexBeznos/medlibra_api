# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    module Jwt
      class Payload < Dry::Validation::Contract
        PROJECT_ID = Medlibra::Container["settings"]
                     .firebase_project_id
                     .freeze

        ISSUER_HOST = "https://securetoken.google.com"

        ISSUER = [
          ISSUER_HOST,
          PROJECT_ID,
        ].join("/").freeze

        json do
          # Expiration time must be in the future
          required(:exp).value(:integer)

          # Issued-at time must be in the past
          required(:iat).value(:integer)

          # Audience must be Firebase project id
          required(:aud).value(:str?, eql?: PROJECT_ID)

          # Subject / ( User id | Device id )
          required(:sub).value(:str?, min_size?: 3)

          # Issuer
          required(:iss).value(:str?, eql?: ISSUER)

          # Authenticatiton time must be in the past.
          required(:auth_time).value(:integer)
        end

        rule(:exp) do
          key.failure("must be in future") unless Time.now < Time.at(values[:exp])
        end

        rule(:iat) do
          key.failure("must be in past") unless Time.now > Time.at(values[:iat])
        end

        rule(:auth_time) do
          key.failure("must be in past") unless Time.now > Time.at(values[:auth_time])
        end
      end
    end
  end
end
