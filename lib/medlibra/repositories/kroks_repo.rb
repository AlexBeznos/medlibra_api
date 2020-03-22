# frozen_string_literal: true

require "medlibra/repository"

module Medlibra
  module Repositories
    class KroksRepo < Medlibra::Repository[:kroks]
      def for_dictionary
        kroks.combine(:fields)
      end
    end
  end
end
