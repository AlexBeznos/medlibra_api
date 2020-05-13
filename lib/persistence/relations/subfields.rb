# frozen_string_literal: true

require "types"

module Persistence
  module Relations
    class Subfields < ROM::Relation[:sql]
      schema(:subfields, infer: true) do
        attribute :id, ::Types::Strict::Integer
        attribute :name, ::Types::Strict::String

        primary_key :id

        associations do
          has_many :assessments
        end
      end

      auto_struct(false)
      auto_map(false)

      def subjects_page(krok_id:, field_id:)
        join(assessments)
          .where(assessments[:krok_id] => krok_id)
          .where(assessments[:field_id] => field_id)
          .distinct
      end
    end
  end
end
