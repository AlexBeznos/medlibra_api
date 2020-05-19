# frozen_string_literal: true

require "types"
require "medlibra/repository"

module Medlibra
  module Repositories
    class AssessmentsRepo < Medlibra::Repository[:assessments]
      def exams_page(user_id:, **page_params)
        assessments
          .exams_page(**page_params)
          .with_attempts_by_user(user_id: user_id)
          .to_a
      end

      def subfields_page(user_id:, **page_params)
        assessments
          .subfields_page(**page_params)
          .with_attempts_by_user(user_id: user_id)
          .to_a
      end
    end
  end
end
