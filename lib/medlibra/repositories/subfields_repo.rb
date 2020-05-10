# frozen_string_literal: true

require "medlibra/repository"

module Medlibra
  module Repositories
    class SubfieldsRepo < Medlibra::Repository[:subfields]
      def subjects_page(krok_id:, field_id:)
        subfields.subjects_page(
          krok_id: krok_id,
          field_id: field_id,
        ).to_a
      end
    end
  end
end
