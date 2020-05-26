# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    module Attempts
      class ForCreate < Dry::Validation::Contract
        json do
          required(:question_id).value(:integer)
          required(:choosen_answer_id).value(:integer)
        end
      end
    end
  end
end
