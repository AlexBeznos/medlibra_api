# frozen_string_literal: true

require "medlibra/import"

module Medlibra
  module Transactions
    module Dictionary
      class Get
        FIELD_KEYS = %i[id name].freeze

        include Import["repositories.kroks_repo"]

        def call
          kroks_repo
            .for_dictionary
            .to_a
            .map(&:to_h)
            .tap(&method(:serialize))
        end

        private

        def serialize(records)
          records.each do |krok|
            krok[:fields] = krok[:fields].map do |field|
              field.slice(*FIELD_KEYS)
            end
          end
        end
      end
    end
  end
end
