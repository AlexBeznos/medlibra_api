# frozen_string_literal: true

require "dry/validation"
require "medlibra/container"

module Medlibra
  module Validations
    module Bookmarks
      class ForCreate < Dry::Validation::Contract
        option(
          :questions_repo,
          default: lambda do
            Medlibra::Container["repositories.questions_repo"]
          end,
        )

        json do
          required(:question_id).value(:integer)
        end

        rule(:question_id) do
          key.failure("is not exist") unless questions_repo.questions.exist?(id: values[:question_id])
        end
      end
    end
  end
end
