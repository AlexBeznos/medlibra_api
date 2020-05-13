# frozen_string_literal: true

require "types"
require "medlibra/repository"

module Medlibra
  module Repositories
    class AssessmentsRepo < Medlibra::Repository[:assessments]
      def exams_page(krok_id:, field_id:)
        assessments
          .exams_page(krok_id: krok_id, field_id: field_id)
          .combine(:year)
          .to_a
      end
    end
  end
end
