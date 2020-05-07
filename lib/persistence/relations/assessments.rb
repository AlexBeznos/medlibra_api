# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Assessments < ROM::Relation[:sql]
      schema(:assessments, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :type, ::Types::AssessmentTypes
        attribute :questions_amount, ::Types::Strict::Integer

        primary_key :id

        associations do
          belongs_to :krok
          belongs_to :field
          belongs_to :subfield
          belongs_to :year
        end
      end
    end
  end
end
