# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    module AssessmentChunks
      class ForCreate < Dry::Validation::Contract
        json do
          required(:chunk_size).value(:integer)
        end
      end
    end
  end
end
