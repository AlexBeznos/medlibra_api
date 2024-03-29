# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    class ForPagination < Dry::Validation::Contract
      params do
        optional(:limit).value(:integer, gt?: 0, lteq?: 10)
        optional(:offset).value(:integer, gteq?: 0)
      end
    end
  end
end
