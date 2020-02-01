# frozen_string_literal: true

require "dry/validation"

module Medlibra
  module Validations
    module Jwt
      class Header < Dry::Validation::Contract
        json do
          required(:alg).value(:str?, eql?: "RS256")
          required(:kid).value(:string)
        end
      end
    end
  end
end
