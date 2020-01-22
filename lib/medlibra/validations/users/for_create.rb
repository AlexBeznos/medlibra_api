require "dry/validation"

module Medlibra
  module Validations
    module Users
      class ForCreate < Dry::Validation::Contract
        json do
          required(:username).value(:string)
        end
      end
    end
  end
end

